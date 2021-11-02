defmodule Skeleton.Query do
  @moduledoc """
  Skeleton Query module
  """

  alias Skeleton.Query.Config

  @callback start_query(Map.t()) :: Ecto.Query.t()

  defmacro __using__(opts) do
    alias Skeleton.Query
    alias Skeleton.Query.Config

    quote do
      @behaviour Skeleton.Query
      @module __MODULE__
      @repo unquote(opts[:repo]) || Config.repo() || raise("Repo required")

      def all(params, opts \\ []), do: Query.all(@module, @repo, params, opts)

      def one(params, opts \\ []), do: Query.one(@module, @repo, params, opts)

      def aggregate(params, aggregate, field, opts \\ []),
        do: Query.aggregate(@module, @repo, params, aggregate, field, opts)

      def build_query(params, opts \\ []), do: Query.build_query(@module, params, opts)

      @before_compile Skeleton.Query
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def filter_by(query, _, _args), do: query
      def sort_by(query, _, _args), do: query

      defoverridable filter_by: 3, sort_by: 3
    end
  end

  def all(module, repo, params, opts) do
    module
    |> prepare_query(params, opts)
    |> repo.all(prefix: get_prefix(opts))
  end

  def one(module, repo, params, opts) do
    module
    |> prepare_query(params, opts)
    |> repo.one(prefix: get_prefix(opts))
  end

  def aggregate(module, repo, params, aggregate, field, opts) do
    module
    |> prepare_query(params, opts)
    |> repo.aggregate(aggregate, field, prefix: get_prefix(opts))
  end

  def build_query(module, params, opts) do
    prepare_query(module, params, opts)
  end

  # Get prefix

  defp get_prefix(opts) do
    opts[:prefix] || "public"
  end

  # Prepare query

  defp prepare_query(module, params, opts) do
    params = stringfy_map(params)

    module
    |> build_start_query(params, opts)
    |> build_filters(module, params)
    |> build_sorts(module, params)
  end

  # Start query

  defp build_start_query(module, params, opts) do
    if start_query = opts[:start_query] do
      start_query
    else
      module.start_query(params)
    end
  end

  # Build filters

  defp build_filters(query, module, params) do
    Enum.reduce(params, query, fn f, query ->
      apply(module, :filter_by, [query, f, params])
    end)
  end

  # Build sorts

  defp build_sorts(query, module, params) do
    params
    |> Map.get(Config.sort_param(), [])
    |> Enum.reduce(query, fn o, query ->
      apply(module, :sort_by, [query, o, params])
    end)
  end

  # Stringfy map

  defp stringfy_map(map) do
    stringkeys = fn {k, v}, acc ->
      Map.put_new(acc, to_string(k), v)
    end

    Enum.reduce(map, %{}, stringkeys)
  end
end
