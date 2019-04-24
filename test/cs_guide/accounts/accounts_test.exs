defmodule CsGuide.AccountsTest do
  use CsGuide.DataCase

  describe "users" do
    alias CsGuide.Accounts.User

    @valid_attrs %{email: "some@email"}
    @update_attrs %{email: "some@updated.email"}
    @invalid_attrs %{email: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        %User{}
        |> User.changeset(Enum.into(attrs, @valid_attrs))
        |> User.insert()

      user
    end

    test "all/0 returns all users" do
      user_fixture()
      assert length(User.all()) == 1
    end

    test "get/1 returns the user with given id" do
      user = user_fixture()
      assert User.get(user.entry_id).email == user.email
    end

    test "insert/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = %User{} |> User.changeset(@valid_attrs) |> User.insert()
      assert user.email == "some@email"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               %User{} |> User.changeset(@invalid_attrs) |> User.insert()
    end

    test "update/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = User.changeset(user, @update_attrs) |> User.update()
      assert %User{} = user
      assert user.email == "some@updated.email"
    end

    test "update/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = User.changeset(user, @invalid_attrs) |> User.update()
    end

    test "changeset/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = User.changeset(user)
    end

    test "cannot duplicate email addresses" do
      user_fixture()
      assert {:error, user_2} = %User{} |> User.changeset(@valid_attrs) |> User.insert()
    end
  end
end
