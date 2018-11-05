defmodule CsGuide.ResourcesTest do
  use CsGuide.DataCase

  alias CsGuide.Resources

  describe "venues" do
    alias CsGuide.Resources.Venue

    @valid_attrs %{
      phone_number: "some phone_number",
      postcode: "some postcode",
      venue_name: "some venue_name"
    }
    @update_attrs %{
      phone_number: "some updated phone_number",
      postcode: "some updated postcode",
      venue_name: "some updated venue_name"
    }
    @invalid_attrs %{phone_number: nil, postcode: nil, venue_name: nil}

    def venue_fixture(attrs \\ %{}) do
      {:ok, venue} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Venue.insert()

      venue
    end

    test "all/0 returns all venues" do
      venue = venue_fixture()
      assert Venue.all() == [venue]
    end

    test "get/1 returns the venue with given id" do
      venue = venue_fixture()
      assert Venue.get(venue.id) == venue
    end

    test "insert/1 with valid data creates a venue" do
      assert {:ok, %Venue{} = venue} = Venue.insert(@valid_attrs)
      assert venue.phone_number == "some phone_number"
      assert venue.postcode == "some postcode"
      assert venue.venue_name == "some venue_name"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Venue.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the venue" do
      venue = venue_fixture()
      assert {:ok, venue} = Venue.update(venue, @update_attrs)
      assert %Venue{} = venue
      assert venue.phone_number == "some updated phone_number"
      assert venue.postcode == "some updated postcode"
      assert venue.venue_name == "some updated venue_name"
    end

    test "update/2 with invalid data returns error changeset" do
      venue = venue_fixture()
      assert {:error, %Ecto.Changeset{}} = Venue.update(venue, @invalid_attrs)
      assert venue == Venue.get(venue.id)
    end

    test "changeset/1 returns a venue changeset" do
      venue = venue_fixture()
      assert %Ecto.Changeset{} = Venue.changeset(venue)
    end
  end

  describe "drinks" do
    alias CsGuide.Resources.Drink

    @valid_attrs %{abv: 120.5, brand: "some brand", name: "some name"}
    @update_attrs %{abv: 456.7, brand: "some updated brand", name: "some updated name"}
    @invalid_attrs %{abv: nil, brand: nil, name: nil}

    def drink_fixture(attrs \\ %{}) do
      {:ok, drink} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Drink.insert()

      drink
    end

    test "all/0 returns all drinks" do
      drink = drink_fixture()
      assert Drink.all() == [drink]
    end

    test "get/1 returns the drink with given id" do
      drink = drink_fixture()
      assert Drink.get(drink.id) == drink
    end

    test "insert/1 with valid data creates a drink" do
      assert {:ok, %Drink{} = drink} = Drink.insert(@valid_attrs)
      assert drink.abv == 120.5
      assert drink.brand == "some brand"
      assert drink.name == "some name"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Drink.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the drink" do
      drink = drink_fixture()
      assert {:ok, drink} = Drink.update(drink, @update_attrs)
      assert %Drink{} = drink
      assert drink.abv == 456.7
      assert drink.brand == "some updated brand"
      assert drink.name == "some updated name"
    end

    test "update/2 with invalid data returns error changeset" do
      drink = drink_fixture()
      assert {:error, %Ecto.Changeset{}} = Drink.update(drink, @invalid_attrs)
      assert drink == Drink.get_drink!(drink.id)
    end

    test "changeset/1 returns a drink changeset" do
      drink = drink_fixture()
      assert %Ecto.Changeset{} = Drink.changeset(drink)
    end
  end

  describe "brands" do
    alias CsGuide.Resources.Brand

    @valid_attrs %{
      description: "some description",
      logo: "some logo",
      member: true,
      name: "some name",
      website: "some website"
    }
    @update_attrs %{
      description: "some updated description",
      logo: "some updated logo",
      member: false,
      name: "some updated name",
      website: "some updated website"
    }
    @invalid_attrs %{description: nil, logo: nil, member: nil, name: nil, website: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Brand.insert()

      brand
    end

    test "all/0 returns all brands" do
      brand = brand_fixture()
      assert Brand.all() == [brand]
    end

    test "get/1 returns the brand with given id" do
      brand = brand_fixture()
      assert Brand.get(brand.id) == brand
    end

    test "insert/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Brand.insert(@valid_attrs)
      assert brand.description == "some description"
      assert brand.logo == "some logo"
      assert brand.member == true
      assert brand.name == "some name"
      assert brand.website == "some website"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Brand.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the brand" do
      brand = brand_fixture()
      assert {:ok, brand} = Brand.update(brand, @update_attrs)
      assert %Brand{} = brand
      assert brand.description == "some updated description"
      assert brand.logo == "some updated logo"
      assert brand.member == false
      assert brand.name == "some updated name"
      assert brand.website == "some updated website"
    end

    test "update/2 with invalid data returns error changeset" do
      brand = brand_fixture()
      assert {:error, %Ecto.Changeset{}} = Brand.update(brand, @invalid_attrs)
      assert brand == Brand.get_brand!(brand.id)
    end

    test "changeset/1 returns a brand changeset" do
      brand = brand_fixture()
      assert %Ecto.Changeset{} = Brand.changeset(brand)
    end
  end
end
