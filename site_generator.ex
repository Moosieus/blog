# Plan:
# - Read the files
# - Parse the markdown
# - Generate some html

Mix.install([{:earmark, "~> 1.4.46"}])

"""
- `index.md` should be the page loaded for a folder path
- Each post will need a front matter:
  - Title
  - Description (also generate a meta tag here)
- `{name}.md` should always translate to `{name}.html` in the same folder
- I'll need to generate a `sitemap.xml`
- The final site files should be minified

- Walk the file tree
- Parse each file into structured data
-
"""
