defmodule Blog.Post do
  alias Blog.Post
  require Logger

  @enforce_keys [
    :author,
    :contributors,
    :title,
    :body,
    :created_at,
    :modified_at,
    :filename
  ]
  defstruct [
    :author,
    :contributors,
    :title,
    :body,
    :description,
    :created_at,
    :modified_at,
    :order_priority,
    :filename
  ]

  @type t :: %Blog.Post{
          author: String.t(),
          contributors: list(String.t()),
          title: String.t(),
          body: String.t(),
          created_at: DateTime.t(),
          modified_at: DateTime.t(),
          order_priority: integer(),
          filename: String.t()
        }

  def build(filename, attrs, body) do
    {author, contributors} = authors_and_contributors(filename)
    {created_at, modified_at} = time_modified(filename)

    struct!(
      __MODULE__,
      [
        author: author,
        contributors: contributors,
        created_at: created_at,
        modified_at: modified_at,
        body: body,
        filename: Path.basename(filename, ".md"),
        order_priority: 999
      ] ++ Map.to_list(attrs)
    )
  end

  def compare(a = %Post{}, b = %Post{}) do
    case DateTime.compare(a.created_at, b.created_at) do
      :gt -> :gt
      :lt -> :lt
      :eq ->
        cond do
          a.order_priority < b.order_priority -> :lt
          a.order_priority > b.order_priority -> :gt
          true -> :eq
        end
    end
  end

  @spec authors_and_contributors(binary()) :: {binary(), [binary()]}
  # Retrieves the authors and contributors for the given file from git.
  defp authors_and_contributors(path) when is_binary(path) do
    case git_log_authors(path) do
      {"", 0} ->
        {author, 0} = System.shell("git config user.name")
        {String.trim(author), []}

      {authors, 0} ->
        [author | contributors] = String.split(authors, "\n", trim: true)
        {author, contributors}
    end
  end

  defp git_log_authors(path) when is_binary(path) do
    System.shell("git log --reverse --format=%an -- #{path}")
  end

  @spec time_modified(binary()) :: {DateTime.t(), DateTime.t()}
  # Retrieves the specified file's creation and last modified date from the current branch of it.
  defp time_modified(path) when is_binary(path) do
    case git_log_timestamps(path) do
      {"", _} ->
        Logger.warning("#{path} isn't comitted, defaulting timestamps to now")
        now = DateTime.now!("Etc/UTC")

        {now, now}

      {output_str, 0} ->
        timestamps = String.split(output_str, "\n", trim: true)

        {created_at(path, timestamps), modified_at(path, timestamps)}
    end
  end

  defp git_log_timestamps(path) do
    System.shell("git log --follow --format=%ad --date iso8601-strict -- \"#{path}\"")
  end

  defp created_at(path, timestamps) do
    case DateTime.from_iso8601(List.last(timestamps)) do
      {:ok, timestamp, _} ->
        timestamp

      _ ->
        Logger.warning("invalid created_at timestamp for #{path}, defaulting to now.")
        DateTime.now!("Etc/UTC")
    end
  end

  defp modified_at(path, timestamps) do
    case DateTime.from_iso8601(List.first(timestamps)) do
      {:ok, timestamp, _} ->
        timestamp

      _ ->
        Logger.warning("invalid modified_at timestamp for #{path}, defaulting to now.")
        DateTime.now!("Etc/UTC")
    end
  end
end
