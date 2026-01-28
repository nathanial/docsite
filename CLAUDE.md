# Docsite

Documentation website for the Lean 4 workspace.

## Build Commands

```bash
./build.sh    # Build the executable (required before running)
./run.sh      # Build and start the server
lake test     # Run tests
```

**Important:** Use `./build.sh` instead of `lake build`. The default lake target only builds the library, not the executable. The build script ensures the server binary is compiled.

## Development

The server runs on http://localhost:3000 by default.

### Project Structure

- `Docsite/Data/Projects.lean` - Project definitions and documentation content
- `Docsite/Pages/` - Page handlers (Home, Category, Project)
- `templates/` - Handlebars templates
- `public/` - Static assets (CSS, images)

### Adding Documentation

To add documentation for a project, define a `ProjectDoc` in `Projects.lean`:

```lean
def myProjectDoc : ProjectDoc := {
  overview := "<p>HTML overview content</p>"
  installation := "<pre><code>require myproject from ...</code></pre>"
  quickStart := "<p>Quick start example</p>"
  sections := [
    { title := "Section Title", content := "<p>Section content</p>" }
  ]
}
```

Then reference it in the project entry:

```lean
{ name := "MyProject", slug := "myproject", ...,
  documentation := some myProjectDoc }
```
