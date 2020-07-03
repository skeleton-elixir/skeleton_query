# Sobre o Skeleton Query

O Skeleton Query ajuda a criar composes para queries feitas usando o Ecto.Repo.

```elixir
def deps do
  [
    {:skeleton_query, github: "skeleton-elixir/skeleton_query"},
  ]
end
```

## Criando o serviço

```elixir
defmodule App.Query do
  defmacro __using__(_) do
    quote do
      use Skeleton.Query, repo: App.Repo
      import Ecto.{Changeset, Query}
      alias App.Repo
    end
  end
end
```

```elixir
defmodule App.Accounts.UserQuery do
  use App.Query

  def start_query(_context) do
    from(u in Skeleton.App.User)
  end

  def filter_by(query, {:id, id}, _context) do
    where(query, id: ^id)
  end

  def filter_by(query, {:admin, admin}, _context) do
    where(query, admin: ^admin)
  end

  def filter_by(query, {:name, name}, _context) do
    where(query, name: ^name)
  end

  def sort_by(query, :name, _context) do
    order_by(query, asc: :name)
  end

  def sort_by(query, :name_desc, _context) do
    order_by(query, desc: :name)
  end
end
```

## Exemplo de chamada do serviço

```elixir
App.Accounts.UserQuery.all(%{
  id: user.id,
  sort_by: ["inserted_at", "name"]
})
```
