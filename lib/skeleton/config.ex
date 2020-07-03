defmodule Skeleton.Query.Config do
  def repo, do: config(:repo)

  def query, do: config(:query)

  def sort_param, do: config(:sort_param) || :sort_by

  def config(key, default \\ nil) do
    Application.get_env(:skeleton_query, key, default)
  end
end