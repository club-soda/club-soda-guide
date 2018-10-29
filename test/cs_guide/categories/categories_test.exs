defmodule CsGuide.CategoriesTest do
  use CsGuide.DataCase

  alias CsGuide.Categories
  alias CsGuide.Categories.VenueType

  describe "venue_type" do
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
      assert {:ok, %VenueType{} = venue_types} = Categories.create_venue_types(@valid_attrs)
      assert venue_types.type == "some type"
    end

    test "create_venue_types/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_venue_types(@invalid_attrs)
    end

    test "update_venue_types/2 with valid data updates the venue_types" do
      venue_types = venue_types_fixture()
      assert {:ok, venue_types} = Categories.update_venue_types(venue_types, @update_attrs)
      assert %VenueType{} = venue_types
      assert venue_types.type == "some updated type"
    end

    test "update_venue_types/2 with invalid data returns error changeset" do
      venue_types = venue_types_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Categories.update_venue_types(venue_types, @invalid_attrs)

      assert venue_types == Categories.get_venue_types!(venue_types.id)
    end

    test "delete_venue_types/1 deletes the venue_types" do
      venue_types = venue_types_fixture()
      assert {:ok, %VenueType{}} = Categories.delete_venue_types(venue_types)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_venue_types!(venue_types.id) end
    end

    test "change_venue_types/1 returns a venue_types changeset" do
      venue_types = venue_types_fixture()
      assert %Ecto.Changeset{} = Categories.change_venue_types(venue_types)
    end
  end

  describe "drink_styles" do
    alias CsGuide.Categories.DrinkStyle

    @valid_attrs %{deleted: true, entry_id: "some entry_id", name: "some name"}
    @update_attrs %{deleted: false, entry_id: "some updated entry_id", name: "some updated name"}
    @invalid_attrs %{deleted: nil, entry_id: nil, name: nil}

    def drink_style_fixture(attrs \\ %{}) do
      {:ok, drink_style} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Categories.create_drink_style()

      drink_style
    end

    test "list_drink_styles/0 returns all drink_styles" do
      drink_style = drink_style_fixture()
      assert Categories.list_drink_styles() == [drink_style]
    end

    test "get_drink_style!/1 returns the drink_style with given id" do
      drink_style = drink_style_fixture()
      assert Categories.get_drink_style!(drink_style.id) == drink_style
    end

    test "create_drink_style/1 with valid data creates a drink_style" do
      assert {:ok, %DrinkStyle{} = drink_style} = Categories.create_drink_style(@valid_attrs)
      assert drink_style.deleted == true
      assert drink_style.entry_id == "some entry_id"
      assert drink_style.name == "some name"
    end

    test "create_drink_style/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_drink_style(@invalid_attrs)
    end

    test "update_drink_style/2 with valid data updates the drink_style" do
      drink_style = drink_style_fixture()
      assert {:ok, drink_style} = Categories.update_drink_style(drink_style, @update_attrs)
      assert %DrinkStyle{} = drink_style
      assert drink_style.deleted == false
      assert drink_style.entry_id == "some updated entry_id"
      assert drink_style.name == "some updated name"
    end

    test "update_drink_style/2 with invalid data returns error changeset" do
      drink_style = drink_style_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Categories.update_drink_style(drink_style, @invalid_attrs)

      assert drink_style == Categories.get_drink_style!(drink_style.id)
    end

    test "delete_drink_style/1 deletes the drink_style" do
      drink_style = drink_style_fixture()
      assert {:ok, %DrinkStyle{}} = Categories.delete_drink_style(drink_style)
      assert_raise Ecto.NoResultsError, fn -> Categories.get_drink_style!(drink_style.id) end
    end

    test "change_drink_style/1 returns a drink_style changeset" do
      drink_style = drink_style_fixture()
      assert %Ecto.Changeset{} = Categories.change_drink_style(drink_style)
    end
  end
end
