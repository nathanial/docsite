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

- `Docsite/Data/Projects.lean` - Project metadata (name, slug, description)
- `Docsite/Data/DocLoader.lean` - Loads documentation from template files
- `Docsite/Pages/` - Page handlers (Home, Category, Project, Section)
- `templates/` - Handlebars templates
- `templates/docs/` - Per-project documentation content
- `public/` - Static assets (CSS, images)

### Adding Documentation

Documentation content is stored in `templates/docs/{project-slug}/` as numbered `.html.hbs` files:

```
templates/docs/myproject/
├── 00-overview.html.hbs         # Overview shown on project page
├── 01-installation.html.hbs     # First section
├── 02-quick-start.html.hbs      # Second section
├── 03-core-concepts.html.hbs    # Additional sections...
└── ...
```

**Naming Convention:**
- Files are ordered by 2-digit numeric prefix: `00-`, `01-`, `02-`, etc.
- Slug is derived from filename: `03-core-types.html.hbs` → slug `core-types`
- Title is derived from slug: `core-types` → "Core Types"
- `00-overview.html.hbs` is special - rendered on the project page itself

**Example content (`templates/docs/myproject/00-overview.html.hbs`):**

```html
<p>MyProject is a library for doing things.</p>

<h3>Key Features</h3>
<ul>
  <li><strong>Feature 1</strong> - Description</li>
  <li><strong>Feature 2</strong> - Description</li>
</ul>
```

Each file should contain raw HTML content (no template directives needed).

### Hot Reload

Templates are loaded at runtime, so you can edit `.html.hbs` files and see changes by refreshing the browser (no rebuild needed for content changes).
