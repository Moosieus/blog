defmodule Blog.Index do
  require EEx

  EEx.function_from_file(:def, :exec, "lib/blog/index.eex", [:assigns])
end
