defmodule Skeleton.Query do
  alias Skeleton.Query.Config

  @callback start_query(Map.t()) :: Ecto.Query.t()

  defmacro __using__(opts) do
    alias Skeleton.Query
    alias Skeleton.Query.Config

    quote do
      @behaviour Skeleton.Query
      @module __MODULE__
      @repo unquote(opts[:repo]) || Config.repo() || raise("Repo required")

      def all(context, opts \\ []), do: Query.all(@module, @repo, context, opts)

      def one(context, opts \\ []), do: Query.one(@module, @repo, context, opts)

      def aggregate(context, aggregate, field, opts \\ []),
        do: Query.aggregate(@module, @repo, context, aggregate, field, opts)

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

  def all(module, repo, context, opts) do
    module
    |> prepare_query(context)
    |> repo.all(prefix: get_prefix(opts))
  end

  def one(module, repo, context, opts) do
    module
    |> prepare_query(context)
    |> repo.one(prefix: get_prefix(opts))
  end

  def aggregate(module, repo, context, aggregate, field, opts) do
    module
    |> prepare_query(context)
    |> repo.aggregate(aggregate, field, prefix: get_prefix(opts))
  end

  # Get prefix

  defp get_prefix(opts) do
    opts[:prefix] || "public"
  end

  # Prepare query

  defp prepare_query(module, context) do
    context
    |> module.start_query()
    |> build_filters(module, context)
    |> build_sorts(module, context)
  end

  # Build filters

  defp build_filters(query, module, context) do
    Enum.reduce(context, query, fn f, query ->
      apply(module, :filter_by, [query, f, context])
    end)
  end

  # Build sorts

  defp build_sorts(query, module, context) do
    context
    |> Map.get(Config.sort_param(), [])
    |> Enum.map(&String.to_atom/1)
    |> Enum.reduce(query, fn o, query ->
      apply(module, :sort_by, [query, o, context])
    end)
  end
end
