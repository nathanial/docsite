import Lake
open Lake DSL

package docsite where
  version := v!"0.1.0"

require loom from git "https://github.com/nathanial/loom" @ "v0.1.3"
require crucible from git "https://github.com/nathanial/crucible" @ "v0.0.9"
require chronicle from git "https://github.com/nathanial/chronicle" @ "v0.0.1"
require staple from git "https://github.com/nathanial/staple" @ "v0.0.3"

-- OpenSSL linking (required by citadel's TLS support via loom)
def opensslLinkArgs : Array String :=
  #["-L/opt/homebrew/opt/openssl@3/lib", "-lssl", "-lcrypto"]

@[default_target]
lean_lib Docsite where
  roots := #[`Docsite]
  moreLinkArgs := opensslLinkArgs

lean_exe docsite where
  root := `Docsite.Main
  moreLinkArgs := opensslLinkArgs

lean_lib Tests where
  roots := #[`Tests]

@[test_driver]
lean_exe docsite_tests where
  root := `Tests.Main
  moreLinkArgs := opensslLinkArgs
