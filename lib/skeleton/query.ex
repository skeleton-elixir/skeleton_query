defmodule Skeleton.Query do
  alias Skeleton.Query.Config, as: QueryConfig

  # Callbacks

  @callback start_query(Map.t()) :: Ecto.Query.t()

  defmacro __using__(opts) do
    alias Skeleton.Query, as: Qry
    alias Skeleton.Query.Config, as: QueryConfig

    quote do
      @behaviour Skeleton.Query
      @repo unquote(opts[:repo]) || QueryConfig.repo()

      def all(context), do: Qry.all(__MODULE__, @repo, context)

      def one(context), do: Qry.one(__MODULE__, @repo, context)

      def aggregate(context, aggregate, field),
        do: Qry.aggregate(__MODULE__, @repo, context, aggregate, field)

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

  # All

  def all(module, repo, context) do
    module
    |> prepare_query(context)
    |> repo.all()
  end

  def one(module, repo, context) do
    module
    |> prepare_query(context)
    |> repo.one()
  end

  def aggregate(module, repo, context, aggregate, field) do
    module
    |> prepare_query(context)
    |> repo.aggregate(aggregate, field)
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
    |> Map.get(QueryConfig.sort_param(), [])
    |> Enum.map(&String.to_atom/1)
    |> Enum.reduce(query, fn o, query ->
      apply(module, :sort_by, [query, o, context])
    end)
  end
end
