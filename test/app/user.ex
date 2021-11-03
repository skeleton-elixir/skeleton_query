defmodule Skeleton.App.User do
  @moduledoc false

  use Skeleton.App, :schema

  schema "users" do
    field :name, :string
    field :email, :string
    field :admin, :boolean

    has_many(:posts, Skeleton.App.Post)

    timestamps()
  end
end
