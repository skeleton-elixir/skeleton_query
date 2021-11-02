defmodule Skeleton.Query.Config do
  @moduledoc """
  Skeleton Query Config module
  """
  def repo, do: config(:repo)

  def sort_param, do: to_string(config(:sort_param, "sort_by"))

  def config(key, default \\ nil) do
    Application.get_env(:skeleton_query, key, default)
  end
end
