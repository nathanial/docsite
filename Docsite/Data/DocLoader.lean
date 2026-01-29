/-
  Docsite.Data.DocLoader - Load documentation content from template files

  Documentation is stored in templates/docs/{project}/ as numbered .html.hbs files:
    00-overview.html.hbs
    01-installation.html.hbs
    02-quick-start.html.hbs
    ...

  The numeric prefix determines ordering. Slugs and titles are derived from filenames.
-/

namespace Docsite.Data.DocLoader

/-- Information about a documentation section -/
structure DocSectionInfo where
  order : Nat       -- Numeric ordering from filename (e.g., 03)
  slug : String     -- Slug for URL (e.g., "core-types")
  title : String    -- Display title (e.g., "Core Types")
  deriving Repr, BEq, Inhabited

/-- Loaded documentation content for a project -/
structure LoadedDoc where
  overview : String                    -- Content from 00-overview.html.hbs
  sections : List (DocSectionInfo × String)  -- (info, content) pairs
  deriving Repr, Inhabited

/-- Convert a Nat to a 2-digit zero-padded string (e.g., 3 → "03") -/
def padOrder (n : Nat) : String :=
  let s := toString n
  if s.length < 2 then "0" ++ s else s

/-- Capitalize the first character of a string -/
def capitalizeFirst (s : String) : String :=
  match s.toList with
  | [] => ""
  | c :: cs => String.mk (c.toUpper :: cs)

/-- Convert a slug to a display title by capitalizing words and replacing hyphens with spaces -/
def slugToTitle (slug : String) : String :=
  slug.splitOn "-"
    |>.map capitalizeFirst
    |>.intersperse " "
    |>.foldl (· ++ ·) ""

/-- Parse a documentation filename into (order, slug)
    Example: "03-core-types.html.hbs" → some (3, "core-types") -/
def parseDocFilename (filename : String) : Option (Nat × String) := do
  -- Remove .html.hbs extension
  guard (filename.endsWith ".html.hbs")
  let base := filename.dropRight 9  -- ".html.hbs".length = 9

  -- Split on first hyphen: "03-core-types" → "03", "core-types"
  let parts := base.splitOn "-"
  guard (parts.length >= 2)

  let orderStr := parts.head!
  guard (orderStr.length == 2)  -- Expect 2-digit prefix like "00", "01", ...

  let order ← orderStr.toNat?
  let slug := "-".intercalate parts.tail!
  pure (order, slug)

/-- Read a template file, returning none if it doesn't exist -/
def loadTemplateFile (path : System.FilePath) : IO (Option String) := do
  if ← path.pathExists then
    let content ← IO.FS.readFile path
    pure (some content)
  else
    pure none

/-- Get the docs directory path for a project -/
def docsPath (templatesDir : System.FilePath) (projectSlug : String) : System.FilePath :=
  templatesDir / "docs" / projectSlug

/-- Scan a project's docs directory and return section info sorted by order.
    Excludes 00-overview which is handled separately. -/
def scanDocDirectory (templatesDir : System.FilePath) (projectSlug : String)
    : IO (List DocSectionInfo) := do
  let dir := docsPath templatesDir projectSlug
  if ← dir.pathExists then
    let entries ← dir.readDir
    let sections := entries.toList.filterMap fun entry =>
      match parseDocFilename entry.fileName with
      | some (order, slug) =>
        -- Skip 00-overview, it's special
        if order == 0 then none
        else some { order, slug, title := slugToTitle slug : DocSectionInfo }
      | none => none
    -- Sort by order
    pure (sections.toArray.qsort (·.order < ·.order)).toList
  else
    pure []

/-- Load all documentation for a project -/
def loadProjectDoc (templatesDir : System.FilePath) (projectSlug : String)
    : IO (Option LoadedDoc) := do
  let dir := docsPath templatesDir projectSlug
  -- Check if overview exists
  let overviewPath := dir / "00-overview.html.hbs"
  match ← loadTemplateFile overviewPath with
  | none => pure none
  | some overview =>
    -- Scan for sections
    let sectionInfos ← scanDocDirectory templatesDir projectSlug
    -- Load each section's content
    let sections ← sectionInfos.mapM fun info => do
      let filename := s!"{padOrder info.order}-{info.slug}.html.hbs"
      let path := dir / filename
      let content ← loadTemplateFile path
      pure (info, content.getD "")
    pure (some { overview, sections })

/-- Load a specific section's content by slug -/
def loadSection (templatesDir : System.FilePath) (projectSlug : String) (sectionSlug : String)
    : IO (Option String) := do
  let dir := docsPath templatesDir projectSlug
  if ← dir.pathExists then
    let entries ← dir.readDir
    for entry in entries do
      match parseDocFilename entry.fileName with
      | some (_, slug) =>
        if slug == sectionSlug then
          return ← loadTemplateFile (dir / entry.fileName)
      | none => pure ()
    pure none
  else
    pure none

/-- Get list of projects that have documentation (i.e., have a docs/{slug}/ directory) -/
def getDocumentedProjects (templatesDir : System.FilePath) : IO (List String) := do
  let docsDir := templatesDir / "docs"
  if ← docsDir.pathExists then
    let entries ← docsDir.readDir
    let projects ← entries.toList.filterMapM fun entry => do
      if ← (docsDir / entry.fileName).isDir then
        -- Verify it has at least an overview
        let overviewPath := docsDir / entry.fileName / "00-overview.html.hbs"
        if ← overviewPath.pathExists then
          pure (some entry.fileName)
        else
          pure none
      else
        pure none
    pure projects
  else
    pure []

/-- Check if a project has documentation -/
def hasDocumentation (templatesDir : System.FilePath) (projectSlug : String) : IO Bool := do
  let overviewPath := docsPath templatesDir projectSlug / "00-overview.html.hbs"
  overviewPath.pathExists

/-- Get section info for sidebar building (without loading content) -/
def getSectionInfos (templatesDir : System.FilePath) (projectSlug : String)
    : IO (List DocSectionInfo) :=
  scanDocDirectory templatesDir projectSlug

end Docsite.Data.DocLoader
