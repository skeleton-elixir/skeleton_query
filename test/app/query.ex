defmodule Skeleton.App.Query do
  @moduledoc false

  defmacro __using__(opts) do
    quote do
      use Skeleton.Query, unquote(opts)

      import Ecto.Query
      import Skeleton.App.Query
    end
  end
end
