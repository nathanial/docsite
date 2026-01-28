/-
  Docsite.Pages.Project - Individual project pages
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

def projectData (p : Project) : Stencil.Value :=
  .object #[
    ("title", .string p.name),
    ("name", .string p.name),
    ("slug", .string p.slug),
    ("category", .string p.category),
    ("categorySlug", .string p.categorySlug),
    ("description", .string p.description)
  ]

page project "/project/:slug" GET (slug : String) do
  match findProject slug with
  | some p =>
    Loom.Stencil.ActionM.renderWithLayout "main" "project" (projectData p)
  | none =>
    html "<h1>Project not found</h1>"

end Docsite.Pages
