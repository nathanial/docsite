/-
  Tests.Main - Test runner entry point
-/
import Crucible
import Docsite.Data.Projects

namespace Tests.Docsite

open Crucible
open Docsite.Data.Projects

testSuite "Docsite"

test "allProjects has 66 projects" := do
  allProjects.length ≡ 66

test "categories has 9 categories" := do
  categories.length ≡ 9

test "findProject returns Some for existing project" := do
  match findProject "terminus" with
  | some p => p.name ≡ "Terminus"
  | none => throw (IO.userError "Expected to find terminus")

test "findProject returns None for non-existent project" := do
  match findProject "nonexistent" with
  | some _ => throw (IO.userError "Expected None for nonexistent")
  | none => pure ()

test "projectsByCategory returns correct count for Graphics" := do
  let graphics := projectsByCategory "graphics"
  graphics.length ≡ 11

test "categoryProjectCounts matches allProjects" := do
  let totalFromCounts := categoryProjectCounts.foldl (fun acc (_, _, count) => acc + count) 0
  totalFromCounts ≡ allProjects.length

end Tests.Docsite

open Crucible in
def main : IO UInt32 := runAllSuites
