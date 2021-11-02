# Sobre o Skeleton Query

O Skeleton Query ajuda a criar composes para queries feitas usando o Ecto.Repo.

OBS: Cuidado ao passar todo o `params` para dentro do seu arquivo `Query`, pois ele não estará tratando parâmetros permitidos. Utilize as opções `allow` e `deny` dos métodos `all`, `one` e `aggregate` do Skeleton Query para resolver essa questão.

## Instalação e configuração

```elixir
# mix.exs

def deps do
  [
    {:skeleton_query, "~> 1.5.0"}
  ]
end
```

```elixir
# config/config.exs

config :skeleton_query,
  repo: App.Repo, # Default Repo
  sort_param: "sort_by"
```

```elixir
# lib/app/query.ex

defmodule App.Query do
  defmacro __using__(opts) do
    quote do
      use Skeleton.Query, unquote(opts)

      import Ecto.Query
      import App.Query
    end
  end
end
```

## Criando o serviço

```elixir
# lib/app/accounts/user/user_query.ex

defmodule App.Accounts.UserQuery do
  use App.Query, repo: App.Query # Override the default Repo

  def start_query(_params) do
    from(u in Skeleton.App.User)
  end

  def end_query(query, _params) do
    order_by(query, asc: :name)
  end

  # Filters

  def filter_by(query, {"id", id}, _params) do
    where(query, id: ^id)
  end

  def filter_by(query, {"admin", admin}, _params) do
    where(query, admin: ^admin)
  end

  def compose(query, {"name", name}, _params) do
    where(query, name: ^name)
  end

  # Sorts

  def sort_by(query, "name", _params) do
    order_by(query, asc: :name)
  end

  def sort_by(query, "name_desc", _params) do
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

App.Accounts.UserQuery.one(%{id: "123"}, allow: [:id])

App.Accounts.UserQuery.aggregate(%{admin: true}, :count, :id, deny: [:email])

App.Accounts.UserQuery.build_query(%{id: "123"}, deny: [:email])
```