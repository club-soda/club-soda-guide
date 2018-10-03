defmodule CsGuide.CategoriesTest do
  use CsGuide.DataCase

  alias CsGuide.Categories

  describe "venue_type" do
    alias CsGuide.Categories.VenueTypes

    @valid_attrs %{type: "some type"}
    @update_attrs %{type: "some updated type"}
    @invalid_attrs %{type: nil}

    def venue_types_fixture(attrs \\ %{}) do
      {:ok, venue_types} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Categories.create_venue_types()

      venue_types
    end

    test "list_venue_type/0 returns all venue_type" do
      venue_types = venue_types_fixture()
      assert Categories.list_venue_type() == [venue_types]
    end

    test "get_venue_types!/1 returns the venue_types with given id" do
      venue_types = venue_types_fixture()
      assert Categories.get_venue_types!(venue_types.id) == venue_types
    end

    test "create_venue_types/1 with valid data creates a venue_types" do
      assert {:ok, %VenueTypes{} = venue_types} = Categories.create_venue_types(@valid_attrs)
      assert venue_types.type == "some type"
    end

    test "create_venue_types/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_venue_types(@invalid_attrs)
    end

    test "update_venue_types/2 with valid data updates the venue_types" do
      venue_types = venue_types_fixture()
      assert {:ok, venue_types} = Categories.update_venue_types(venue_types, @update_attrs)
      assert %VenueTypes{} = venue_types
      assert venue_types.type == "some updated type"
    end

    test "update_venue_types/2 with invalid data returns error changeset" do
      venue_types = venue_types_fixture()
      assert {:error, %Ecto.Changeset{}} = Categories.update_venue_types(venue_types, @invalid_attrs)
      assert venue_types == Categories.get_venue_types!(venue_types.id)
    end

    test "delete_venue_types/1 deletes the venue_types" do
      venue_types = venue_types_fixture()
      assert {:ok, %VenueTypes{}} = Categories.delete_venue_types(venue_types)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_venue_types!(venue_types.id) end
    end

    test "change_venue_types/1 returns a venue_types changeset" do
      venue_types = venue_types_fixture()
      assert %Ecto.Changeset{} = Categories.change_venue_types(venue_types)
    end
  end
end
