defmodule Skeleton.App.UserQuery do
  use Skeleton.App.Query

  alias Skeleton.App.User

  def start_query(_context) do
    from(u in User)
  end

  def filter_by(query, {"id", id}, _context) do
    where(query, id: ^id)
  end

  def filter_by(query, {"admin", admin}, _context) do
    where(query, admin: ^admin)
  end

  def filter_by(query, {"name", name}, _context) do
    where(query, name: ^name)
  end

  def sort_by(query, "name", _context) do
    order_by(query, asc: :name)
  end

  def sort_by(query, "name_desc", _context) do
    order_by(query, desc: :name)
  end
end
