defmodule Skeleton.QueryTest do
  @moduledoc false

  use Skeleton.Query.TestCase
  alias Skeleton.App.{User, Post, UserQuery, PostQuery}

  setup ctx do
    user1 = create_user(id: Ecto.UUID.generate(), name: "User A", admin: true)
    user2 = create_user(id: Ecto.UUID.generate(), name: "User B", admin: true)
    user3 = create_user(id: Ecto.UUID.generate(), name: "User C", admin: false)

    ctx
    |> Map.put(:user1, user1)
    |> Map.put(:user2, user2)
    |> Map.put(:user3, user3)
  end

  # Query all

  test "search all filtering by id", ctx do
    [user] = UserQuery.all(%{id: ctx.user1.id})
    assert user.id == ctx.user1.id
  end

  test "search all changing start query", ctx do
    query = from(u in User, where: [id: ^ctx.user1.id])
    [user] = UserQuery.all(%{}, start_query: query)
    assert user.id == ctx.user1.id
  end

  test "search all filtering by admin", ctx do
    users = UserQuery.all(%{admin: true})
    assert length(users) == 2
    assert Enum.find(users, &(&1.id == ctx.user1.id))
    assert Enum.find(users, &(&1.id == ctx.user2.id))
  end

  test "search all filtering by id and admin", ctx do
    [user] = UserQuery.all(%{name: ctx.user1.name, admin: true})
    assert user.id == ctx.user1.id

    assert UserQuery.all(%{id: ctx.user3.id, admin: true}) == []
  end

  # Query one

  test "search one filtering by id", ctx do
    user = UserQuery.one(%{id: ctx.user1.id})
    assert user.id == ctx.user1.id
  end

  test "search one changing start query", ctx do
    query = from(u in User, where: [id: ^ctx.user1.id])
    user = UserQuery.one(%{}, start_query: query)
    assert user.id == ctx.user1.id
  end

  test "search one filtering by id and admin", ctx do
    user = UserQuery.one(%{name: ctx.user1.name, admin: true})
    assert user.id == ctx.user1.id

    assert UserQuery.one(%{id: ctx.user3.id, admin: true}) == nil
  end

  test "search one sorting by name asc", ctx do
    [u1, u2, u3] = UserQuery.all(%{sort_by: ["name"]})
    assert [u1.id, u2.id, u3.id] == [ctx.user1.id, ctx.user2.id, ctx.user3.id]
  end

  # Query sorting

  test "search all sorting by name desc", ctx do
    [u1, u2, u3] = UserQuery.all(%{sort_by: ["name_desc"]})
    assert [u1.id, u2.id, u3.id] == [ctx.user3.id, ctx.user2.id, ctx.user1.id]
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

  test "build query from filter by id", ctx do
    query = UserQuery.build_query(%{id: ctx.user1.id})
    assert %Ecto.Query{} = query
  end

  # End query

  test "search all with end query", ctx do
    [u1, u2, u3] = UserQuery.all()
    assert [u1.id, u2.id, u3.id] == [ctx.user3.id, ctx.user2.id, ctx.user1.id]
  end

  # Allow params

  test "search all allowing some params", ctx do
    assert UserQuery.all(%{id: ctx.user1.id, admin: false}) == []

    [user] = UserQuery.all(%{id: ctx.user1.id, admin: false}, allow: [:id])
    assert user.id == ctx.user1.id
  end

  test "aggregate allowing some params", ctx do
    total = UserQuery.aggregate(%{id: ctx.user1.id, admin: true}, :count, :id, allow: [:admin])
    assert total == 2
  end

  test "search all allowing some params with sort_by", ctx do
    res =
      UserQuery.all(%{id: ctx.user1.id, sort_by: ["wrong_sort_by"]},
        allow: [:id, sort_by: [:wrong_sort_by]]
      )

    assert res == []

    res =
      UserQuery.all(%{id: ctx.user1.id, sort_by: ["wrong_sort_by"]},
        allow: [:id, :sort_by]
      )

    assert res == []

    [user] =
      UserQuery.all(%{id: ctx.user1.id, sort_by: ["wrong_sort_by"]},
        allow: [:id]
      )

    assert user.id == ctx.user1.id
  end

  # Deny params

  test "search all denying some params", ctx do
    assert UserQuery.all(%{id: ctx.user1.id, admin: false}) == []

    [user] = UserQuery.all(%{id: ctx.user1.id, admin: false}, deny: [:admin])
    assert user.id == ctx.user1.id
  end

  test "aggregate denying some params", ctx do
    total = UserQuery.aggregate(%{id: ctx.user1.id, admin: true}, :count, :id, deny: [:admin])
    assert total == 1
  end

  test "search all denying some params with sort_by", ctx do
    [user] =
      UserQuery.all(%{id: ctx.user1.id, sort_by: ["wrong_sort_by"]},
        deny: [sort_by: [:wrong_sort_by]]
      )

    assert user.id == ctx.user1.id

    [user] =
      UserQuery.all(%{id: ctx.user1.id, sort_by: ["wrong_sort_by"]},
        deny: [:sort_by]
      )

    assert user.id == ctx.user1.id

    [u1, u2, u3] =
      UserQuery.all(%{id: ctx.user1.id, sort_by: ["wrong_sort_by", "user_name_desc"]},
        deny: [:id, sort_by: [:wrong_sort_by]]
      )

    assert u1.id == ctx.user3.id
    assert u2.id == ctx.user2.id
    assert u3.id == ctx.user1.id
  end

  # Join new

  test "search all using join new", ctx do
    post1 = create_post(%{id: Ecto.UUID.generate(), user_id: ctx.user1.id})
    post2 = create_post(%{id: Ecto.UUID.generate(), user_id: ctx.user2.id})
    _post3 = create_post(%{id: Ecto.UUID.generate(), user_id: ctx.user3.id})

    [p1, p2] = PostQuery.all(%{user_admin: true, sort_by: ["user_name_desc"]})

    assert p1.id == post2.id
    assert p2.id == post1.id
  end

  # Crete user

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

  # Crete post

  defp create_post(params) do
    %Post{
      id: params[:id],
      title: "Title #{params[:id]}",
      body: "Body...",
      user_id: params[:user_id]
    }
    |> change(params)
    |> Repo.insert!()
  end
end
