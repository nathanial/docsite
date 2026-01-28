/-
  Docsite.Pages.Project - Individual project pages
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

/-- Convert a title to an anchor slug -/
def titleToAnchor (title : String) : String :=
  title.toLower
    |>.replace " " "-"
    |>.replace "/" "-"

/-- Convert a DocSection to a Stencil value -/
def docSectionToValue (sec : DocSection) : Stencil.Value :=
  .object #[
    ("title", .string sec.title),
    ("anchor", .string (titleToAnchor sec.title)),
    ("content", .string sec.content)
  ]

/-- Convert a ProjectDoc to a Stencil value -/
def projectDocToValue (doc : ProjectDoc) : Stencil.Value :=
  .object #[
    ("overview", .string doc.overview),
    ("installation", .string doc.installation),
    ("quickStart", .string doc.quickStart),
    ("sections", .array (doc.sections.map docSectionToValue).toArray)
  ]

def projectData (p : Project) : Stencil.Value :=
  let baseFields := #[
    ("title", .string p.name),
    ("name", .string p.name),
    ("slug", .string p.slug),
    ("category", .string p.category),
    ("categorySlug", .string p.categorySlug),
    ("description", .string p.description)
  ]
  let allFields := match p.documentation with
    | some doc => baseFields.push ("documentation", projectDocToValue doc)
    | none => baseFields
  .object allFields

page project "/project/:slug" GET (slug : String) do
  match findProject slug with
  | some p =>
    let data := projectData p
    let withSidebar := match data with
      | .object fields => .object (fields.push
          ("sidebar", sidebarToValue (buildSidebar (some p.categorySlug) (some p.slug))))
      | other => other
    Loom.Stencil.ActionM.renderWithLayout "main" "project" withSidebar
  | none =>
    html "<h1>Project not found</h1>"

end Docsite.Pages
