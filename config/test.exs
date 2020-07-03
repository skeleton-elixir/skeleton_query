use Mix.Config

config :skeleton_query, ecto_repos: [Skeleton.App.Repo]

config :skeleton_query, Skeleton.App.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "skeleton_query_test",
  username: System.get_env("SKELETON_QUERY_DB_USER") || System.get_env("USER") || "postgres"

config :logger, :console, level: :error

config :skeleton_query,
  query: Skeleton.App.Query,
  repo: Skeleton.App.Repo,
  sort_param: :sort_by