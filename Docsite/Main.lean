/-
  Docsite.Main - Application setup and entry point
-/
import Loom
import Loom.Stencil
import Chronicle
import Docsite.Pages

namespace Docsite

open Loom
open Docsite.Pages

/-- Application configuration -/
def config : AppConfig := {
  secretKey := "docsite-secret-key-minimum-32-chars!!".toUTF8
  sessionCookieName := "docsite_session"
  csrfFieldName := "_csrf"
  csrfEnabled := false
}

/-- Build the application with all routes -/
def buildApp : App :=
  Loom.app config
    |> registerPages
    |>.withStencil { templateDir := "templates", extension := ".html.hbs", hotReload := true }

/-- Main entry point (inside namespace) -/
def runApp : IO Unit := do
  IO.println "Starting Docsite..."
  IO.println "Visit http://localhost:3000"
  let app := buildApp
  app.run "0.0.0.0" 3000

end Docsite

/-- Top-level main entry point for executable -/
def main : IO Unit := Docsite.runApp
