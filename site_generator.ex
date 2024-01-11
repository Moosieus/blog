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

An index file will be generated for each directory by reading each "child" file's front matter.
If an `index.md file's present, it'll be displayed as content above the index section.`

Parsing a file:
- Return the front matter as a map
- Return the content as semantic html
"""

defmodule ParseError do
  defexception [:message]

  def message(%{message: message}), do: message

  def new(message), do: %__MODULE__{message: message}
end

defmodule Parser do
  def parse(path) do
    file = File.read!(path)

    try do
      case String.split(file, "---\n", parts: 3) do
        ["", front_matter, content] ->
          %{
            name: Path.basename(path),
            front_matter: parse_front_matter(front_matter),
            content: parse_content(content)
          }

        _ ->
          raise ParseError.new("expected valid front matter, got none.")
      end
    rescue
      e in ParseError ->
        raise "parse \"#{path}\": #{Exception.message(e)}"
    end
  end

  defp parse_content(content), do: Earmark.as_html!(content)

  def parse_front_matter(content) do
    content
    |> String.split("\n", trim: true)
    |> Enum.with_index(&parse_front_matter_line/2)
    |> validate_required()
  end

  defp parse_front_matter_line(line, index) do
    case String.split(line, ": ", parts: 2) do
      [key, value] ->
        {key, value}

      _ ->
        raise ParseError.new("front matter line #{index} invalid: \"#{line}\"")
    end
  end

  defp validate_required(front_matter) when is_list(front_matter) do
    require_field(front_matter, "title")
    require_field(front_matter, "description")

    front_matter
  end

  defp require_field(front_matter, key) when is_list(front_matter) do
    List.keyfind(front_matter, key, 0) || raise ParseError.new("\"#{key}\" required in front matter")
  end
end

"""
- Walk the file path
- Spin up a parser for each
-
"""
