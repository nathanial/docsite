/-
  Docsite.Data.Projects - Project data for all 66 workspace projects

  Note: Documentation content is now loaded from templates/docs/{slug}/ at runtime.
  See Docsite.Data.DocLoader for the loading logic.
-/

namespace Docsite.Data.Projects

/-- A project in the workspace -/
structure Project where
  name : String
  slug : String
  category : String
  categorySlug : String
  description : String
  deriving Repr, BEq

/-- All project categories -/
def categories : List (String × String) := [
  ("Graphics", "graphics"),
  ("Web", "web"),
  ("Network", "network"),
  ("Data", "data"),
  ("Apps", "apps"),
  ("Util", "util"),
  ("Math", "math"),
  ("Audio", "audio"),
  ("Testing", "testing")
]

/-- All 66 projects in the workspace -/
def allProjects : List Project := [
  -- Graphics (11 projects)
  { name := "Terminus", slug := "terminus", category := "Graphics", categorySlug := "graphics",
    description := "Terminal user interface (TUI) library for building interactive terminal applications" },
  { name := "Afferent", slug := "afferent", category := "Graphics", categorySlug := "graphics",
    description := "Metal GPU rendering framework with Arbor/Canopy widget system for macOS" },
  { name := "Afferent Demos", slug := "afferent-demos", category := "Graphics", categorySlug := "graphics",
    description := "Demo runner and examples for the Afferent graphics framework" },
  { name := "Trellis", slug := "trellis", category := "Graphics", categorySlug := "graphics",
    description := "CSS-style layout engine for UI positioning and sizing" },
  { name := "Tincture", slug := "tincture", category := "Graphics", categorySlug := "graphics",
    description := "Color manipulation library with support for various color spaces" },
  { name := "Chroma", slug := "chroma", category := "Graphics", categorySlug := "graphics",
    description := "Interactive color picker application built with Afferent" },
  { name := "Assimptor", slug := "assimptor", category := "Graphics", categorySlug := "graphics",
    description := "3D model loading via Assimp library bindings" },
  { name := "Worldmap", slug := "worldmap", category := "Graphics", categorySlug := "graphics",
    description := "Map rendering and visualization application" },
  { name := "Vane", slug := "vane", category := "Graphics", categorySlug := "graphics",
    description := "Terminal emulator implementation" },
  { name := "Raster", slug := "raster", category := "Graphics", categorySlug := "graphics",
    description := "Image loading and manipulation library" },
  { name := "Grove", slug := "grove", category := "Graphics", categorySlug := "graphics",
    description := "File browser application with graphical interface" },

  -- Web (7 projects)
  { name := "Loom", slug := "loom", category := "Web", categorySlug := "web",
    description := "Full-featured web framework for building server-side applications" },
  { name := "Citadel", slug := "citadel", category := "Web", categorySlug := "web",
    description := "HTTP server with TLS support and middleware architecture" },
  { name := "Herald", slug := "herald", category := "Web", categorySlug := "web",
    description := "HTTP request/response parser" },
  { name := "Scribe", slug := "scribe", category := "Web", categorySlug := "web",
    description := "Type-safe HTML builder with composable elements" },
  { name := "Markup", slug := "markup", category := "Web", categorySlug := "web",
    description := "HTML parser for processing web content" },
  { name := "Chronicle", slug := "chronicle", category := "Web", categorySlug := "web",
    description := "Structured logging library with multiple output formats" },
  { name := "Stencil", slug := "stencil", category := "Web", categorySlug := "web",
    description := "Handlebars-style template engine" },

  -- Network (6 projects)
  { name := "Wisp", slug := "wisp", category := "Network", categorySlug := "network",
    description := "HTTP client library with curl bindings" },
  { name := "Legate", slug := "legate", category := "Network", categorySlug := "network",
    description := "gRPC client and server implementation" },
  { name := "Protolean", slug := "protolean", category := "Network", categorySlug := "network",
    description := "Protocol Buffers serialization library" },
  { name := "Oracle", slug := "oracle", category := "Network", categorySlug := "network",
    description := "OpenRouter API client for AI model access" },
  { name := "Jack", slug := "jack", category := "Network", categorySlug := "network",
    description := "Socket programming library for TCP/UDP" },
  { name := "Exchange", slug := "exchange", category := "Network", categorySlug := "network",
    description := "Peer-to-peer chat application" },

  -- Data (14 projects)
  { name := "Ledger", slug := "ledger", category := "Data", categorySlug := "data",
    description := "Fact-based database with Datalog-style queries" },
  { name := "Quarry", slug := "quarry", category := "Data", categorySlug := "data",
    description := "SQLite bindings and database operations" },
  { name := "Chisel", slug := "chisel", category := "Data", categorySlug := "data",
    description := "SQL DSL for type-safe query building" },
  { name := "Cellar", slug := "cellar", category := "Data", categorySlug := "data",
    description := "Disk-based caching system" },
  { name := "Collimator", slug := "collimator", category := "Data", categorySlug := "data",
    description := "Profunctor optics library (lenses, prisms, traversals)" },
  { name := "Convergent", slug := "convergent", category := "Data", categorySlug := "data",
    description := "Conflict-free replicated data types (CRDTs)" },
  { name := "Reactive", slug := "reactive", category := "Data", categorySlug := "data",
    description := "Functional reactive programming (FRP) library" },
  { name := "Tabular", slug := "tabular", category := "Data", categorySlug := "data",
    description := "CSV parsing and generation" },
  { name := "Entity", slug := "entity", category := "Data", categorySlug := "data",
    description := "Entity-component-system (ECS) architecture" },
  { name := "Totem", slug := "totem", category := "Data", categorySlug := "data",
    description := "TOML configuration file parser" },
  { name := "Tileset", slug := "tileset", category := "Data", categorySlug := "data",
    description := "Map tile management and caching" },
  { name := "Galaxy Gen", slug := "galaxy-gen", category := "Data", categorySlug := "data",
    description := "Galaxy generation algorithms (planned)" },

  -- Apps (16 projects)
  { name := "Homebase App", slug := "homebase-app", category := "Apps", categorySlug := "apps",
    description := "Personal dashboard application with multiple modules" },
  { name := "Todo App", slug := "todo-app", category := "Apps", categorySlug := "apps",
    description := "Task management application" },
  { name := "Enchiridion", slug := "enchiridion", category := "Apps", categorySlug := "apps",
    description := "Reference manual and knowledge base application" },
  { name := "Lighthouse", slug := "lighthouse", category := "Apps", categorySlug := "apps",
    description := "Project monitoring and status dashboard" },
  { name := "Blockfall", slug := "blockfall", category := "Apps", categorySlug := "apps",
    description := "Tetris-style falling blocks game" },
  { name := "Twenty48", slug := "twenty48", category := "Apps", categorySlug := "apps",
    description := "2048 puzzle game" },
  { name := "Ask", slug := "ask", category := "Apps", categorySlug := "apps",
    description := "CLI tool for AI-powered queries" },
  { name := "Cairn", slug := "cairn", category := "Apps", categorySlug := "apps",
    description := "Graphical application with Metal rendering" },
  { name := "Minefield", slug := "minefield", category := "Apps", categorySlug := "apps",
    description := "Minesweeper game" },
  { name := "Solitaire", slug := "solitaire", category := "Apps", categorySlug := "apps",
    description := "Card solitaire game" },
  { name := "Tracker", slug := "tracker", category := "Apps", categorySlug := "apps",
    description := "Issue tracking CLI tool" },
  { name := "Timekeeper", slug := "timekeeper", category := "Apps", categorySlug := "apps",
    description := "Time tracking TUI application" },
  { name := "Eschaton", slug := "eschaton", category := "Apps", categorySlug := "apps",
    description := "Grand strategy game with Afferent graphics" },
  { name := "Chatline", slug := "chatline", category := "Apps", categorySlug := "apps",
    description := "Chat application" },
  { name := "Astrometry", slug := "astrometry", category := "Apps", categorySlug := "apps",
    description := "Astronomy calculations (planned)" },

  -- Util (11 projects)
  { name := "Parlance", slug := "parlance", category := "Util", categorySlug := "util",
    description := "CLI argument parsing and command-line interface framework" },
  { name := "Staple", slug := "staple", category := "Util", categorySlug := "util",
    description := "Utility macros and common functionality" },
  { name := "Chronos", slug := "chronos", category := "Util", categorySlug := "util",
    description := "Date and time handling library" },
  { name := "Rune", slug := "rune", category := "Util", categorySlug := "util",
    description := "Regular expression library" },
  { name := "Sift", slug := "sift", category := "Util", categorySlug := "util",
    description := "Parser combinator library" },
  { name := "Conduit", slug := "conduit", category := "Util", categorySlug := "util",
    description := "Channel-based concurrency primitives" },
  { name := "Docgen", slug := "docgen", category := "Util", categorySlug := "util",
    description := "Documentation generation tool" },
  { name := "Tracer", slug := "tracer", category := "Util", categorySlug := "util",
    description := "Debugging and tracing utilities" },
  { name := "Crypt", slug := "crypt", category := "Util", categorySlug := "util",
    description := "Cryptographic operations via libsodium" },
  { name := "Timeout", slug := "timeout", category := "Util", categorySlug := "util",
    description := "Timeout and deadline handling" },
  { name := "Smalltalk", slug := "smalltalk", category := "Util", categorySlug := "util",
    description := "Smalltalk interpreter implementation" },

  -- Math (2 projects)
  { name := "Linalg", slug := "linalg", category := "Math", categorySlug := "math",
    description := "Linear algebra with vectors and matrices" },
  { name := "Measures", slug := "measures", category := "Math", categorySlug := "math",
    description := "Units of measurement and conversions" },

  -- Audio (1 project)
  { name := "Fugue", slug := "fugue", category := "Audio", categorySlug := "audio",
    description := "Audio synthesis and sound generation" },

  -- Testing (1 project)
  { name := "Crucible", slug := "crucible", category := "Testing", categorySlug := "testing",
    description := "Testing framework with assertions and test runners" }
]

/-- Get projects by category slug -/
def projectsByCategory (categorySlug : String) : List Project :=
  allProjects.filter (·.categorySlug == categorySlug)

/-- Find a project by slug -/
def findProject (slug : String) : Option Project :=
  allProjects.find? (·.slug == slug)

/-- Find category name by slug -/
def findCategoryName (slug : String) : Option String :=
  categories.find? (·.2 == slug) |>.map (·.1)

/-- Count projects in each category -/
def categoryProjectCounts : List (String × String × Nat) :=
  categories.map fun (name, slug) =>
    (name, slug, (projectsByCategory slug).length)

end Docsite.Data.Projects
