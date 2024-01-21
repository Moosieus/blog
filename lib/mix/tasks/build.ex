defmodule Mix.Tasks.Build do
  use Mix.Task
  @impl Mix.Task
  def run(_args) do
    {micro, :ok} =
      :timer.tc(fn ->
        File.rm_rf!("./static")
        File.mkdir!("./static")
        File.cp_r!("./content/assets", "./static/assets")
        File.write!("./static/assets/highlight.css", Makeup.stylesheet(:monokai_style, "makeup"))

        Blog.Templates.build()
      end)

    ms = micro / 1000
    IO.puts("BUILT in #{ms}ms")
  end
end
