defmodule CsGuide.CategoriesTest do
  use CsGuide.DataCase

  alias CsGuide.Categories
  alias CsGuide.Categories.{VenueType, DrinkStyle}

  describe "venue_type" do
    @valid_attrs %{name: "some type"}
    @update_attrs %{name: "some updated type"}
    @invalid_attrs %{name: nil}

    def venue_types_fixture(attrs \\ %{}) do
      {:ok, venue_types} =
        attrs
        |> Enum.into(@valid_attrs)
        |> VenueType.insert()

      venue_types
    end

    test "all/0 returns all venue_type" do
      venue_types = venue_types_fixture()
      assert VenueType.all() == [venue_types]
    end

    test "get/1 returns the venue_types with given id" do
      venue_types = venue_types_fixture()
      assert VenueType.get(venue_types.entry_id) == venue_types
    end

    test "insert/1 with valid data creates a venue_types" do
      assert {:ok, %VenueType{} = venue_types} = VenueType.insert(@valid_attrs)
      assert venue_types.name == "some type"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VenueType.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the venue_types" do
      venue_types = venue_types_fixture()
      assert {:ok, venue_types} = VenueType.update(venue_types, @update_attrs)
      assert %VenueType{} = venue_types
      assert venue_types.name == "some updated type"
    end

    test "update/2 with invalid data returns error changeset" do
      venue_types = venue_types_fixture()

      assert {:error, %Ecto.Changeset{}} = VenueType.update(venue_types, @invalid_attrs)

      assert venue_types == VenueType.get(venue_types.entry_id)
    end

    test "changeset/1 returns a venue_types changeset" do
      venue_types = venue_types_fixture()
      assert %Ecto.Changeset{} = VenueType.changeset(venue_types)
    end
  end

  describe "drink_styles" do
    @valid_attrs %{deleted: false, entry_id: "some entry_id", name: "some name"}
    @update_attrs %{deleted: false, entry_id: "some updated entry_id", name: "some updated name"}
    @invalid_attrs %{deleted: nil, entry_id: nil, name: nil}

    def drink_style_fixture(attrs \\ %{}) do
      {:ok, drink_style} =
        attrs
        |> Enum.into(@valid_attrs)
        |> DrinkStyle.insert()

      drink_style
    end

    test "all/0 returns all drink_styles" do
      drink_style = drink_style_fixture()
      assert DrinkStyle.all() == [drink_style]
    end

    test "get/1 returns the drink_style with given id" do
      drink_style = drink_style_fixture()
      assert DrinkStyle.get(drink_style.entry_id) == drink_style
    end

    test "insert/1 with valid data creates a drink_style" do
      assert {:ok, %DrinkStyle{} = drink_style} = DrinkStyle.insert(@valid_attrs)
      assert drink_style.deleted == false
      assert drink_style.entry_id == "some entry_id"
      assert drink_style.name == "some name"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DrinkStyle.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the drink_style" do
      drink_style = drink_style_fixture()
      assert {:ok, drink_style} = DrinkStyle.update(drink_style, @update_attrs)
      assert %DrinkStyle{} = drink_style
      assert drink_style.deleted == false
      assert drink_style.entry_id == "some updated entry_id"
      assert drink_style.name == "some updated name"
    end

    test "update/2 with invalid data returns error changeset" do
      drink_style = drink_style_fixture()

      assert {:error, %Ecto.Changeset{}} = DrinkStyle.update(drink_style, @invalid_attrs)

      assert drink_style == DrinkStyle.get(drink_style.entry_id)
    end

    test "changeset/1 returns a drink_style changeset" do
      drink_style = drink_style_fixture()
      assert %Ecto.Changeset{} = DrinkStyle.changeset(drink_style, %{})
    end
  end
end
