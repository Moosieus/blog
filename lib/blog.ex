defmodule Blog do
  @moduledoc false

  use NimblePublisher,
    build: Blog.Post,
    from: Path.absname("content/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang],
    earmark_options: %Earmark.Options{
      compact_output: true,
      smartypants: false,
      wikilinks: true
    }

  @posts Enum.sort_by(@posts, & &1.created_at, {:desc, DateTime})

  @spec all_posts() :: list(Blog.Post.t())
  def all_posts, do: @posts
end
