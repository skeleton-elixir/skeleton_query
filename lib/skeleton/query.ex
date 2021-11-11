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

      def all(params \\ %{}, opts \\ []), do: Query.all(@module, @repo, params, opts)

      def one(params \\ %{}, opts \\ []), do: Query.one(@module, @repo, params, opts)

      def aggregate(params, aggregate, field, opts \\ []),
        do: Query.aggregate(@module, @repo, params, aggregate, field, opts)

      def build_query(params, opts \\ []), do: Query.build_query(@module, params, opts)

      def end_query(query, _params), do: query

      @before_compile Skeleton.Query
      defoverridable end_query: 2
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def compose(query, _, _params), do: query

      defoverridable compose: 3, end_query: 2
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
    params =
      params
      |> stringfy_map()
      |> allow_sort_by_params(opts[:allow])
      |> deny_sort_by_params(opts[:deny])
      |> allow_params(opts[:allow])
      |> deny_params(opts[:deny])

    module
    |> build_start_query(params, opts)
    |> build_composers(module, params)
    |> build_sort_by_composers(module, params)
    |> build_end_query(module, params)
  end

  # Start query

  defp build_start_query(module, params, opts) do
    if start_query = opts[:start_query] do
      start_query
    else
      module.start_query(params)
    end
  end

  # Build composers

  defp build_composers(query, module, params) do
    Enum.reduce(params, query, fn f, query ->
      apply(module, :compose, [query, f, params])
    end)
  end

  # Build sort by composers

  defp build_sort_by_composers(query, module, params) do
    params
    |> Map.get(Config.sort_param(), [])
    |> Enum.reduce(query, fn o, query ->
      apply(module, :compose, [query, {Config.sort_param(), o}, params])
    end)
  end

  # Start query

  defp build_end_query(query, module, params) do
    module.end_query(query, params)
  end

  # Stringfy map

  defp stringfy_map(map) do
    stringkeys = fn {k, v}, acc ->
      Map.put_new(acc, to_string(k), v)
    end

    Enum.reduce(map, %{}, stringkeys)
  end

  # Allow sort by params

  defp allow_sort_by_params(params, nil), do: params

  defp allow_sort_by_params(params, allow) do
    allow
    |> Keyword.get(String.to_atom(Config.sort_param()))
    |> case do
      p when is_list(p) ->
        allow = Enum.map(p, &to_string/1)
        sort_params = params[Config.sort_param()] || []
        allowed_sort = sort_params -- sort_params -- allow
        Map.put(params, Config.sort_param(), allowed_sort)

      _ ->
        params
    end
  end

  # Deny sort by params

  defp deny_sort_by_params(params, nil), do: params

  defp deny_sort_by_params(params, deny) do
    deny
    |> Keyword.get(String.to_atom(Config.sort_param()))
    |> case do
      p when is_list(p) ->
        deny = Enum.map(p, &to_string/1)
        sort_params = params[Config.sort_param()] || []
        allowed_sort = sort_params -- deny

        Map.put(params, Config.sort_param(), allowed_sort)

      _ ->
        params
    end
  end

  # Allow params

  defp allow_params(params, nil), do: params

  defp allow_params(params, allow) do
    allow =
      Enum.map(allow, fn a ->
        case a do
          a when is_atom(a) -> to_string(a)
          a when is_binary(a) -> a
          {k, _} -> to_string(k)
          _ -> ""
        end
      end)

    Map.take(params, allow)
  end

  # deny params

  defp deny_params(params, nil), do: params

  defp deny_params(params, deny) do
    deny =
      Enum.map(deny, fn a ->
        case a do
          a when is_atom(a) -> to_string(a)
          a when is_binary(a) -> a
          {k, _} -> to_string(k)
          _ -> ""
        end
      end)

    Map.drop(params, deny)
  end
end
