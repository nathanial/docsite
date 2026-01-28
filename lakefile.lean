import Lake
open Lake DSL

package docsite where
  version := v!"0.1.0"

require crucible from git "https://github.com/nathanial/crucible" @ "v0.0.9"

@[default_target]
lean_lib Udocsite where
  roots := #[`Udocsite]

lean_exe docsite where
  root := `Udocsite.Main

lean_lib Tests where
  roots := #[`Tests]

@[test_driver]
lean_exe docsite_tests where
  root := `Tests.Main
