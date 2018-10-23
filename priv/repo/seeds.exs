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
  {"Nanny State", "Brewdog", "Beer", "0.5",
   "Packed with loads of Centennial, Amarillo, Columbus, Cascade and Simcoe hops, dry hopped to the brink and back and sitting at 45 IBUS, Nanny State is a force to be reckoned with."},
  {"0.0", "Heineken", "Beer", "0.0",
   "Heineken 0.0 Lager 0.0% is a balanced thirst quencher with refreshing fruity notes and a soft malty body."},
  {"Cucumber & Mint", "Nix and Kix", "Soft Drink", "0.0", " "},
  {"Peach & Vanilla", "Nix and Kix", "Soft Drink", "0.0", " "},
  {"Stout", "Big Drop", "Beer", "0.5",
   "With notes of coffee, cocoa nibs and a lingering hint of sweet vanilla this beer is dark, rich and indulgent. "},
  {"Pale Ale", "Big Drop", "Beer", "0.5",
   "This dry-hopped pale ale is deliciously refreshing. The nose has hints of pine and honey. Packed full of flavour from citrus-heavy hops with a twist of fresh lime to create a crisp, zesty beer. "},
  {"Lager", "Big Drop", "Beer", "0.5",
   "Aromas of cracker, light honey and pepper this lager is crisp, balanced with a suitable level of bitterness to ensure it has a dry, refreshing bite."},
  {"Shiraz", "Belvoir Drinks", "Wine", "0.0",
   "It has a very ‘grown-up’ taste with a nose of blackcurrant, a touch of vanilla and a semi-sweet fruity flavour with an astringent, slightly mouth drying finish and a hint of spice typically associated with a Shiraz red wine. Just like the alcoholic variety this rich dark red alcohol-free version slips down nicely with steak or boeuf bourguignon."}
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

Enum.map(drinks, fn {n, b, t, a, d} ->
  Drink.insert(%{
    "name" => n,
    "drink_types" => Map.new([{t, "on"}]),
    "brand" => Map.new([{b, "on"}]),
    "abv" => a,
    "description" => d
  })
end)
