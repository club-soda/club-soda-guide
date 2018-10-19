# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CsGuide.Repo.insert!(%CsGuide.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CsGuide.Resources.{Brand, Drink, Venue}
alias CsGuide.Categories.{DrinkType, VenueType, DrinkStyle}

brands = [
  {"Brewdog", "Scottish Craft Beer"},
  {"Heineken", "Dutch Beer"},
  {"Nix and Kix", "Adult Soft Drinks"},
  {"Big Drop", "Low Alcohol Craft Beer"},
  {"Belvoir Drinks", "Naturally Lovely Drinks"}
]

drink_types = ["Beer", "Wine", "Soft Drink"]

drink_styles = ["Pale Ale", "Lager", "Stouts & Porters", "Red Wine"]

venue_types = ["Pub", "Restaurant", "Cocktail Bar"]

drinks = [
  {"Nanny State", "Brewdog", "Beer", "0.5"},
  {"0.0", "Heineken", "Beer", "0.0"},
  {"Cucumber & Mint", "Nix and Kix", "Soft Drink", "0.0"},
  {"Peach & Vanilla", "Nix and Kix", "Soft Drink", "0.0"},
  {"Stout", "Big Drop", "Beer", "0.5"},
  {"Pale Ale", "Big Drop", "Beer", "0.5"},
  {"Lager", "Big Drop", "Beer", "0.5"},
  {"Shiraz", "Belvoir Drinks", "Wine", "0.0"}
]

venues = [
  {"The Black Dog", "0123456789", "E2 0SY", "Pub"}
]

Enum.map(drink_types, fn b -> DrinkType.insert(%{name: b}) end)
Enum.map(drink_styles, fn b -> DrinkStyle.insert(%{name: b}) end)
Enum.map(venue_types, fn v -> VenueType.insert(%{name: v}) end)
Enum.map(brands, fn {n, d} -> Brand.insert(%{name: n, description: d}) end)

Enum.map(venues, fn {n, ph, p, t} ->
  Venue.insert(%{
    "venue_name" => n,
    "phone_number" => ph,
    "postcode" => p,
    "venue_types" => Map.new([{t, "on"}])
  })
end)

Enum.map(drinks, fn {n, b, t, a} ->
  Drink.insert(%{
    "name" => n,
    "drink_types" => Map.new([{t, "on"}]),
    "brand" => Map.new([{b, "on"}]),
    "abv" => a
  })
end)
