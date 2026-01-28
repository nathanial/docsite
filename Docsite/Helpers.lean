/-
  Docsite.Helpers - Template helpers and utilities
-/
import Stencil

namespace Docsite.Helpers

open Stencil

/-- Merge two Stencil.Value objects -/
def mergeContext (base : Value) (extra : Value) : Value :=
  match base, extra with
  | .object baseFields, .object extraFields =>
    .object (baseFields ++ extraFields)
  | .object baseFields, .null =>
    .object baseFields
  | _, _ => base

end Docsite.Helpers
