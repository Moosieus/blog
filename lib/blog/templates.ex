defmodule Blog.Templates do
  import Phoenix.Template, only: [embed_templates: 1]
  import Phoenix.HTML, only: [raw: 1]

  alias Phoenix.Template

  embed_templates("templates/*")

  def build() do
    posts = Blog.all_posts()

    render("index.html", "index", %{
      title: "Home",
      description: "Index Page",
      posts: posts
    })

    render("404.html", "404")

    for post <- posts do
      render("#{post.filename}.html", "post", %{
        title: post.title,
        description: post.description,
        post: post,
        copyright_date: post.created_at.year
      })
    end

    :ok
  end

  @default_assigns %{
    layout: {__MODULE__, "layout"},
    title: nil,
    description: nil,
    header_content: nil,
    copyright_date: DateTime.utc_now().year
  }

  def render(path, template, assigns \\ %{}) do
    assigns = Map.merge(@default_assigns, assigns)
    safe = Template.render_to_iodata(__MODULE__, template, "html", assigns)

    write_to_static!(path, safe)
  end

  def write_to_static!(path, data) do
    Path.join(["./static", path])
    |> File.write!(data)
  end
end
