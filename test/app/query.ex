defmodule Skeleton.App.Query do
  defmacro __using__(opts) do
    quote do
      use Skeleton.Query, unquote(opts)

      import Ecto.Query
      import Skeleton.App.Query
    end
  end
end
