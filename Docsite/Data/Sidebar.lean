/-
  Docsite.Data.Sidebar - Hierarchical sidebar navigation data
-/
import Stencil
import Docsite.Data.Projects

namespace Docsite.Data.Sidebar

open Docsite.Data.Projects

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

/-- Build sections for a project with documentation -/
def buildProjectSections (doc : ProjectDoc) (currentSectionSlug : Option String := none) : List SidebarSection :=
  -- Fixed sections: installation and quick-start
  let fixed := [
    { title := "Installation", anchor := "installation", active := currentSectionSlug == some "installation" },
    { title := "Quick Start", anchor := "quick-start", active := currentSectionSlug == some "quick-start" }
  ]
  -- Dynamic sections from doc.sections
  let dynamic := doc.sections.map fun sec =>
    let anchor := titleToAnchor sec.title
    { title := sec.title, anchor := anchor, active := currentSectionSlug == some anchor }
  fixed ++ dynamic

/-- Build a sidebar project from a Project -/
def buildSidebarProject (p : Project) (currentProjectSlug : Option String)
    (currentSectionSlug : Option String := none) : SidebarProject :=
  let isActive := currentProjectSlug == some p.slug
  match p.documentation with
  | some doc => {
      name := p.name
      slug := p.slug
      hasDoc := true
      sections := buildProjectSections doc (if isActive then currentSectionSlug else none)
      expanded := isActive
      active := isActive
    }
  | none => {
      name := p.name
      slug := p.slug
      hasDoc := false
      sections := []
      expanded := false
      active := isActive
    }

/-- Build the full sidebar structure -/
def buildSidebar (currentCategorySlug : Option String := none)
    (currentProjectSlug : Option String := none)
    (currentSectionSlug : Option String := none) : List SidebarCategory :=
  categories.map fun (catName, catSlug) =>
    let projects := projectsByCategory catSlug
    let builtProjects := projects.map (buildSidebarProject · currentProjectSlug currentSectionSlug)
    let hasActiveProject := builtProjects.any (·.active)
    {
      name := catName
      slug := catSlug
      projects := builtProjects
      expanded := currentCategorySlug == some catSlug || hasActiveProject
    }

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
