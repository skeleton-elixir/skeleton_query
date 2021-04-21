# Sobre o Skeleton Query

O Skeleton Query ajuda a criar composes para queries feitas usando o Ecto.Repo.

## Instalação

```elixir
# mix.exs

def deps do
  [
    {:skeleton_query, "~> 1.0.0"}
  ]
end
```

```elixir
# lib/app/query.ex

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

## Criando o serviço

```elixir
# lib/app/accounts/user/user_query.ex

defmodule App.Accounts.UserQuery do
  use App.Query

  def start_query(_context) do
    from(u in Skeleton.App.User)
  end

  # Filters

  def filter_by(query, {:id, id}, _context) do
    where(query, id: ^id)
  end

  def filter_by(query, {:admin, admin}, _context) do
    where(query, admin: ^admin)
  end

  def filter_by(query, {:name, name}, _context) do
    where(query, name: ^name)
  end

  # Sorts

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

App.Accounts.UserQuery.one(%{id: "123"})

App.Accounts.UserQuery.aggregate(%{admin: true}, :count, :id)
```