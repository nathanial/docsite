/-
  Docsite.Data.Sidebar - Hierarchical sidebar navigation data
-/
import Stencil
import Docsite.Data.Projects
import Docsite.Data.DocLoader

namespace Docsite.Data.Sidebar

open Docsite.Data.Projects
open Docsite.Data.DocLoader

/-- A section within project documentation for sidebar display -/
structure SidebarSection where
  title : String
  anchor : String  -- e.g., "installation", "quick-start", "core-types"
  active : Bool := false
  deriving Repr

/-- A project in the sidebar hierarchy -/
structure SidebarProject where
  name : String
  slug : String
  hasDoc : Bool
  sections : List SidebarSection  -- Only populated if hasDoc
  expanded : Bool := false
  active : Bool := false
  deriving Repr

/-- A category containing projects -/
structure SidebarCategory where
  name : String
  slug : String
  projects : List SidebarProject
  expanded : Bool := false
  deriving Repr

/-- Convert a title to an anchor slug -/
def titleToAnchor (title : String) : String :=
  title.toLower
    |>.replace " " "-"
    |>.replace "/" "-"

/-- Build sections for a project from DocLoader section infos -/
def buildProjectSections (sectionInfos : List DocSectionInfo) (currentSectionSlug : Option String := none)
    : List SidebarSection :=
  -- All sections come from the file scan (includes 01-installation, 02-quick-start, etc.)
  sectionInfos.map fun info =>
    { title := info.title, anchor := info.slug, active := currentSectionSlug == some info.slug }

/-- Build a sidebar project from a Project (IO version that checks for docs on disk) -/
def buildSidebarProjectIO (templatesDir : System.FilePath) (p : Project)
    (currentProjectSlug : Option String) (currentSectionSlug : Option String := none)
    : IO SidebarProject := do
  let isActive := currentProjectSlug == some p.slug
  let hasDoc ← hasDocumentation templatesDir p.slug
  if hasDoc then
    let sectionInfos ← getSectionInfos templatesDir p.slug
    pure {
      name := p.name
      slug := p.slug
      hasDoc := true
      sections := buildProjectSections sectionInfos (if isActive then currentSectionSlug else none)
      expanded := isActive
      active := isActive
    }
  else
    pure {
      name := p.name
      slug := p.slug
      hasDoc := false
      sections := []
      expanded := false
      active := isActive
    }

/-- Build the full sidebar structure (IO version) -/
def buildSidebarIO (templatesDir : System.FilePath)
    (currentCategorySlug : Option String := none)
    (currentProjectSlug : Option String := none)
    (currentSectionSlug : Option String := none) : IO (List SidebarCategory) := do
  let mut result := []
  for (catName, catSlug) in categories do
    let projects := projectsByCategory catSlug
    let builtProjects ← projects.mapM (buildSidebarProjectIO templatesDir · currentProjectSlug currentSectionSlug)
    let hasActiveProject := builtProjects.any (·.active)
    result := result ++ [{
      name := catName
      slug := catSlug
      projects := builtProjects
      expanded := currentCategorySlug == some catSlug || hasActiveProject
    }]
  pure result

/-- Convert a SidebarSection to a Stencil value -/
def sidebarSectionToValue (sec : SidebarSection) : Stencil.Value :=
  .object #[
    ("title", .string sec.title),
    ("anchor", .string sec.anchor),
    ("active", .bool sec.active)
  ]

/-- Convert a SidebarProject to a Stencil value -/
def sidebarProjectToValue (proj : SidebarProject) : Stencil.Value :=
  .object #[
    ("name", .string proj.name),
    ("slug", .string proj.slug),
    ("hasDoc", .bool proj.hasDoc),
    ("sections", .array (proj.sections.map sidebarSectionToValue).toArray),
    ("expanded", .bool proj.expanded),
    ("active", .bool proj.active)
  ]

/-- Convert a SidebarCategory to a Stencil value -/
def sidebarCategoryToValue (cat : SidebarCategory) : Stencil.Value :=
  .object #[
    ("name", .string cat.name),
    ("slug", .string cat.slug),
    ("projects", .array (cat.projects.map sidebarProjectToValue).toArray),
    ("expanded", .bool cat.expanded)
  ]

/-- Convert the full sidebar to a Stencil value -/
def sidebarToValue (sidebar : List SidebarCategory) : Stencil.Value :=
  .array (sidebar.map sidebarCategoryToValue).toArray

end Docsite.Data.Sidebar
