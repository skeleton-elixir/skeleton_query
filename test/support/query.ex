defmodule Skeleton.App.Query do
  defmacro __using__(_) do
    quote do
      use Skeleton.Query
      import Ecto.{Changeset, Query}
      alias Skeleton.App.{Repo, User}
    end
  end
end