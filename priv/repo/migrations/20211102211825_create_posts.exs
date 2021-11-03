defmodule Skeleton.App.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:user_id, references(:users, on_delete: :nothing, type: :binary_id), null: false)
      add(:title, :string)
      add(:body, :string)

      timestamps()
    end
  end
end
