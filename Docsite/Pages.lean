/-
  Docsite.Pages - Imports all pages and generates routes

  This file imports all page definitions and generates:
  - Route type with a constructor for each page
  - registerPages function to bind handlers
-/
import Docsite.Pages.Home
import Docsite.Pages.Category
import Docsite.Pages.Project
import Docsite.Pages.Section

namespace Docsite.Pages

open Loom.Page

-- Generate Route type and registerPages function from all pages
#generate_pages

end Docsite.Pages
