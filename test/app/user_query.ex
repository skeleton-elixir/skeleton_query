defmodule Skeleton.App.UserQuery do
  @moduledoc false

  use Skeleton.App.Query

  alias Skeleton.App.User

  def start_query(_params) do
    from(u in User)
  end

  def end_query(query, _params) do
    order_by(query, desc: :name)
  end

  def filter_by(query, {"id", id}, _params) do
    where(query, id: ^id)
  end

  def filter_by(query, {"admin", admin}, _params) do
    where(query, admin: ^admin)
  end

  def sort_by(query, "name", _params) do
    order_by(query, asc: :name)
  end

  def compose(query, {"name", name}, _params) do
    where(query, name: ^name)
  end

  def compose(query, {"sort_by", "name_desc"}, _params) do
    order_by(query, desc: :name)
  end
end
