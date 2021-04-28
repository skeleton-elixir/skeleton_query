use Mix.Config

config :skeleton_query, ecto_repos: [Skeleton.App.Repo]

config :skeleton_query, Skeleton.App.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  hostname: System.get_env("POSTGRES_HOST", "localhost"),
  database: "skeleton_query_test",
  password: System.get_env("POSTGRES_PASSWORD", "123456"),
  username: System.get_env("POSTGRES_USERNAME", "postgres")

config :logger, :console, level: :error

config :skeleton_query,
  repo: Skeleton.App.Repo,
  sort_param: :sort_by
