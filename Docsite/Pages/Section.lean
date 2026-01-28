/-
  Docsite.Pages.Section - Individual documentation section pages
-/
import Loom
import Loom.Stencil
import Stencil
import Docsite.Data.Projects
import Docsite.Data.Sidebar

namespace Docsite.Pages

open Loom
open Loom.Page
open Loom.ActionM
open Docsite.Data.Projects
open Docsite.Data.Sidebar

/-- Convert a title to a URL slug -/
def titleToSlug (title : String) : String :=
  title.toLower
    |>.replace " " "-"
    |>.replace "/" "-"

/-- Information about a section for navigation -/
structure SectionInfo where
  title : String
  slug : String
  content : String
  deriving Repr

/-- Get all sections for a project in order -/
def getAllSections (doc : ProjectDoc) : List SectionInfo :=
  let installation : SectionInfo := {
    title := "Installation"
    slug := "installation"
    content := doc.installation
  }
  let quickStart : SectionInfo := {
    title := "Quick Start"
    slug := "quick-start"
    content := doc.quickStart
  }
  let custom := doc.sections.map fun sec => {
    title := sec.title
    slug := titleToSlug sec.title
    content := sec.content
  }
  [installation, quickStart] ++ custom

/-- Find a section by slug -/
def findSectionBySlug (doc : ProjectDoc) (sectionSlug : String) : Option SectionInfo :=
  (getAllSections doc).find? (·.slug == sectionSlug)

/-- Get prev/next section for navigation -/
def getPrevNextSections (doc : ProjectDoc) (sectionSlug : String)
    : Option SectionInfo × Option SectionInfo :=
  let sections := getAllSections doc
  match sections.findIdx? (·.slug == sectionSlug) with
  | none => (none, none)
  | some idx =>
    let prev := if idx > 0 then sections[idx - 1]? else none
    let next := sections[idx + 1]?
    (prev, next)

/-- Convert SectionInfo to Stencil value for navigation -/
def sectionNavToValue (projectSlug : String) (sec : SectionInfo) : Stencil.Value :=
  .object #[
    ("title", .string sec.title),
    ("slug", .string sec.slug),
    ("url", .string s!"/project/{projectSlug}/{sec.slug}")
  ]

page docSection "/project/:projectSlug/:sectionSlug" GET (projectSlug : String) (sectionSlug : String) do
  match findProject projectSlug with
  | none => html "<h1>Project not found</h1>"
  | some p =>
    match p.documentation with
    | none => html "<h1>Documentation not available</h1>"
    | some doc =>
      match findSectionBySlug doc sectionSlug with
      | none => html "<h1>Section not found</h1>"
      | some sec =>
        let (prevSec, nextSec) := getPrevNextSections doc sectionSlug

        -- Build navigation data
        let prevNav := match prevSec with
          | some prev => sectionNavToValue p.slug prev
          | none => .null
        let nextNav := match nextSec with
          | some next => sectionNavToValue p.slug next
          | none => .null

        let data : Stencil.Value := .object #[
          ("title", .string s!"{sec.title} - {p.name}"),
          ("pageTitle", .string sec.title),
          ("projectName", .string p.name),
          ("projectSlug", .string p.slug),
          ("category", .string p.category),
          ("categorySlug", .string p.categorySlug),
          ("sectionContent", .string sec.content),
          ("prevSection", prevNav),
          ("nextSection", nextNav),
          ("sidebar", sidebarToValue (buildSidebar (some p.categorySlug) (some p.slug) (some sectionSlug)))
        ]
        Loom.Stencil.ActionM.renderWithLayout "main" "section" data

end Docsite.Pages
