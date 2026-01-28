/-
  Docsite.Pages.Home - Homepage showing all categories
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

def categoriesData : Stencil.Value :=
  let cats := categoryProjectCounts.map fun (name, slug, count) =>
    Stencil.Value.object #[
      ("name", .string name),
      ("slug", .string slug),
      ("count", .int count)
    ]
  .array cats.toArray

page home "/" GET do
  let data : Stencil.Value := .object #[
    ("title", .string "Documentation"),
    ("categories", categoriesData),
    ("totalProjects", .int allProjects.length)
  ]
  Loom.Stencil.ActionM.renderWithLayout "main" "home" data

end Docsite.Pages
