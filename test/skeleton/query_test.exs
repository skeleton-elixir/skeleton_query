defmodule Skeleton.QueryTest do
  @moduledoc false

  use Skeleton.Query.TestCase
  alias Skeleton.App.{User, UserQuery}

  setup context do
    user1 = create_user(id: Ecto.UUID.generate(), name: "User A", admin: true)
    user2 = create_user(id: Ecto.UUID.generate(), name: "User B", admin: true)
    user3 = create_user(id: Ecto.UUID.generate(), name: "User C")

    context
    |> Map.put(:user1, user1)
    |> Map.put(:user2, user2)
    |> Map.put(:user3, user3)
  end

  # Query all

  test "search all filtering by id", context do
    [user] = UserQuery.all(%{id: context.user1.id})
    assert user.id == context.user1.id
  end

  test "search all changing start query", context do
    query = from(u in User, where: [id: ^context.user1.id])
    [user] = UserQuery.all(%{}, start_query: query)
    assert user.id == context.user1.id
  end

  test "search all filtering by admin", context do
    users = UserQuery.all(%{admin: true})
    assert length(users) == 2
    assert Enum.find(users, &(&1.id == context.user1.id))
    assert Enum.find(users, &(&1.id == context.user2.id))
  end

  test "search all filtering by id and admin", context do
    [user] = UserQuery.all(%{name: context.user1.name, admin: true})
    assert user.id == context.user1.id

    assert UserQuery.all(%{id: context.user3.id, admin: true}) == []
  end

  # Query one

  test "search one filtering by id", context do
    user = UserQuery.one(%{id: context.user1.id})
    assert user.id == context.user1.id
  end

  test "search one changing start query", context do
    query = from(u in User, where: [id: ^context.user1.id])
    user = UserQuery.one(%{}, start_query: query)
    assert user.id == context.user1.id
  end

  test "search one filtering by id and admin", context do
    user = UserQuery.one(%{name: context.user1.name, admin: true})
    assert user.id == context.user1.id

    assert UserQuery.one(%{id: context.user3.id, admin: true}) == nil
  end

  test "search one sorting by name asc", context do
    [u1, u2, u3] = UserQuery.all(%{sort_by: ["name"]})
    assert [u1.id, u2.id, u3.id] == [context.user1.id, context.user2.id, context.user3.id]
  end

  # Query sorting

  test "search all sorting by name desc", context do
    [u1, u2, u3] = UserQuery.all(%{sort_by: ["name_desc"]})
    assert [u1.id, u2.id, u3.id] == [context.user3.id, context.user2.id, context.user1.id]
  end

  # Aggregate

  test "aggregate all filtering by admin" do
    total = UserQuery.aggregate(%{admin: true}, :count, :id)
    assert total == 2
  end

  test "aggregate all changing start query" do
    query = from(u in User, where: [admin: true])
    total = UserQuery.aggregate(%{}, :count, :id, start_query: query)
    assert total == 2
  end

  # Build Query

  test "build query from filter by id", context do
    query = UserQuery.build_query(%{id: context.user1.id})
    assert %Ecto.Query{} = query
  end

  defp create_user(params) do
    %User{
      id: params[:id],
      name: "Name #{params[:id]}",
      email: "email-#{params[:id]}@email.com",
      admin: false
    }
    |> change(params)
    |> Repo.insert!()
  end

  # End query

  test "search all with end query", context do
    [u1, u2, u3] = UserQuery.all()
    assert [u1.id, u2.id, u3.id] == [context.user3.id, context.user2.id, context.user1.id]
  end
end
