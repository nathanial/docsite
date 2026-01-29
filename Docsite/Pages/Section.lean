/-
  Docsite.Pages.Section - Individual documentation section pages
-/
import Loom
import Loom.Stencil
import Stencil
import Docsite.Data.Projects
import Docsite.Data.Sidebar
import Docsite.Data.DocLoader

namespace Docsite.Pages

open Loom
open Loom.Page
open Loom.ActionM
open Docsite.Data.Projects
open Docsite.Data.Sidebar
open Docsite.Data.DocLoader

/-- Information about a section for navigation -/
structure SectionNavInfo where
  title : String
  slug : String
  deriving Repr

/-- Get all sections for a project in order (from template files) -/
def getAllSectionsIO (templatesDir : System.FilePath) (projectSlug : String)
    : IO (List SectionNavInfo) := do
  -- All sections come from the file scan (includes 01-installation, 02-quick-start, etc.)
  let sectionInfos ← getSectionInfos templatesDir projectSlug
  pure (sectionInfos.map fun info => { title := info.title, slug := info.slug })

/-- Find a section by slug and load its content -/
def findSectionBySlugIO (templatesDir : System.FilePath) (projectSlug : String)
    (sectionSlug : String) : IO (Option (SectionNavInfo × String)) := do
  -- Load any section by slug - all sections are discovered from files
  let content ← loadSection templatesDir projectSlug sectionSlug
  match content with
  | some c =>
    let title := slugToTitle sectionSlug
    pure (some ({ title := title, slug := sectionSlug }, c))
  | none => pure none

/-- Get prev/next section for navigation -/
def getPrevNextSectionsIO (templatesDir : System.FilePath) (projectSlug : String)
    (sectionSlug : String) : IO (Option SectionNavInfo × Option SectionNavInfo) := do
  let sections ← getAllSectionsIO templatesDir projectSlug
  match sections.findIdx? (·.slug == sectionSlug) with
  | none => pure (none, none)
  | some idx =>
    let prev := if idx > 0 then sections[idx - 1]? else none
    let next := sections[idx + 1]?
    pure (prev, next)

/-- Convert SectionNavInfo to Stencil value for navigation -/
def sectionNavToValue (projectSlug : String) (sec : SectionNavInfo) : Stencil.Value :=
  .object #[
    ("title", .string sec.title),
    ("slug", .string sec.slug),
    ("url", .string s!"/project/{projectSlug}/{sec.slug}")
  ]

page docSection "/project/:projectSlug/:sectionSlug" GET (projectSlug : String) (sectionSlug : String) do
  match findProject projectSlug with
  | none => html "<h1>Project not found</h1>"
  | some p =>
    let templatesDir := "templates"

    -- Check if this project has documentation
    let hasDoc ← hasDocumentation templatesDir p.slug
    if !hasDoc then
      html "<h1>Documentation not available</h1>"
    else
      -- Find and load the section
      match ← findSectionBySlugIO templatesDir p.slug sectionSlug with
      | none => html "<h1>Section not found</h1>"
      | some (secInfo, content) =>
        let (prevSec, nextSec) ← getPrevNextSectionsIO templatesDir p.slug sectionSlug

        -- Build navigation data
        let prevNav := match prevSec with
          | some prev => sectionNavToValue p.slug prev
          | none => .null
        let nextNav := match nextSec with
          | some next => sectionNavToValue p.slug next
          | none => .null

        -- Build sidebar
        let sidebar ← buildSidebarIO templatesDir (some p.categorySlug) (some p.slug) (some sectionSlug)

        let data : Stencil.Value := .object #[
          ("title", .string s!"{secInfo.title} - {p.name}"),
          ("pageTitle", .string secInfo.title),
          ("projectName", .string p.name),
          ("projectSlug", .string p.slug),
          ("category", .string p.category),
          ("categorySlug", .string p.categorySlug),
          ("sectionContent", .string content),
          ("prevSection", prevNav),
          ("nextSection", nextNav),
          ("sidebar", sidebarToValue sidebar)
        ]
        Loom.Stencil.ActionM.renderWithLayout "main" "section" data

end Docsite.Pages
