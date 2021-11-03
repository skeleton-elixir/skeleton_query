defmodule Skeleton.App.PostQuery do
  @moduledoc false

  use Skeleton.App.Query

  alias Skeleton.App.Post

  def start_query(_params) do
    from(u in Post)
  end

  def filter_by(query, {"id", id}, _params) do
    where(query, id: ^id)
  end

  def compose(query, {"user_admin", admin}, _params) do
    query
    |> join_user()
    |> where([u: u], u.admin == ^admin)
  end

  def compose(query, {"sort_by", "user_name_desc"}, _params) do
    query
    |> join_user()
    |> order_by([u: u], desc: u.name)
  end

  defp join_user(query) do
    if has_named_binding?(query, :u) do
      query
    else
      join(query, :inner, [p], u in assoc(p, :user), [as: :u])
    end
  end
end
