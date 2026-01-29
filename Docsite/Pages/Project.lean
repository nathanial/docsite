/-
  Docsite.Pages.Project - Individual project pages
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

/-- Convert a title to an anchor slug -/
def titleToAnchor (title : String) : String :=
  title.toLower
    |>.replace " " "-"
    |>.replace "/" "-"

/-- Convert loaded doc section info to a Stencil value -/
def docSectionInfoToValue (info : DocSectionInfo) : Stencil.Value :=
  .object #[
    ("title", .string info.title),
    ("anchor", .string info.slug)
  ]

/-- Build documentation value from loaded content -/
def buildDocValue (loadedDoc : LoadedDoc) : Stencil.Value :=
  -- Get sections beyond installation and quick-start (skip first two: 01, 02)
  let customSections := loadedDoc.sections.filter (·.1.order > 2)
  .object #[
    ("overview", .string loadedDoc.overview),
    ("sections", .array (customSections.map (fun (info, _) => docSectionInfoToValue info)).toArray)
  ]

def projectData (p : Project) (documentation : Option LoadedDoc) : Stencil.Value :=
  let baseFields := #[
    ("title", .string p.name),
    ("name", .string p.name),
    ("slug", .string p.slug),
    ("category", .string p.category),
    ("categorySlug", .string p.categorySlug),
    ("description", .string p.description)
  ]
  let allFields := match documentation with
    | some doc => baseFields.push ("documentation", buildDocValue doc)
    | none => baseFields
  .object allFields

page project "/project/:slug" GET (slug : String) do
  match findProject slug with
  | some p =>
    -- Get templates directory from config
    let templatesDir := "templates"

    -- Load documentation from template files
    let loadedDoc ← loadProjectDoc templatesDir p.slug

    let data := projectData p loadedDoc

    -- Build sidebar (IO version)
    let sidebar ← buildSidebarIO templatesDir (some p.categorySlug) (some p.slug)

    let withSidebar := match data with
      | .object fields => .object (fields.push ("sidebar", sidebarToValue sidebar))
      | other => other

    Loom.Stencil.ActionM.renderWithLayout "main" "project" withSidebar
  | none =>
    html "<h1>Project not found</h1>"

end Docsite.Pages
