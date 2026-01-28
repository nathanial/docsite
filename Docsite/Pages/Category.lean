/-
  Docsite.Pages.Category - Category listing pages
-/
import Loom
import Loom.Stencil
import Stencil
import Docsite.Data.Projects

namespace Docsite.Pages

open Loom
open Loom.Page
open Loom.ActionM
open Docsite.Data.Projects

def projectsListData (projects : List Project) : Stencil.Value :=
  let ps := projects.map fun p =>
    Stencil.Value.object #[
      ("name", .string p.name),
      ("slug", .string p.slug),
      ("description", .string p.description)
    ]
  .array ps.toArray

page category "/category/:slug" GET (slug : String) do
  let projects := projectsByCategory slug
  match findCategoryName slug with
  | some categoryName =>
    let data : Stencil.Value := .object #[
      ("title", .string s!"{categoryName} Projects"),
      ("categoryName", .string categoryName),
      ("categorySlug", .string slug),
      ("projects", projectsListData projects),
      ("projectCount", .int projects.length)
    ]
    Loom.Stencil.ActionM.renderWithLayout "main" "category" data
  | none =>
    html "<h1>Category not found</h1>"

end Docsite.Pages
