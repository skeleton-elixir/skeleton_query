defmodule Skeleton.App.Post do
  @moduledoc false

  use Skeleton.App, :schema

  schema "posts" do
    field(:title, :string)
    field(:body, :string)

    belongs_to(:user, Skeleton.App.User)

    timestamps()
  end
end
