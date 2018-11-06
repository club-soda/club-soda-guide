defmodule CsGuide.AccountsTest do
  use CsGuide.DataCase

  alias CsGuide.Accounts

  describe "users" do
    alias CsGuide.Accounts.User

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> User.insert()

      user
    end

    test "all/0 returns all users" do
      user = user_fixture()
      assert User.all() == [user]
    end

    test "get/1 returns the user with given id" do
      user = user_fixture()
      assert User.get(user.entry_id) == user
    end

    test "insert/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = User.insert(@valid_attrs)
      assert user.email == "some email"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = User.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = User.update(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
    end

    test "update/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = User.update(user, @invalid_attrs)
      assert user == User.get(user.entry_id)
    end

    test "changeset/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = User.changeset(user)
    end
  end
end
