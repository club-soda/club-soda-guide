alias CsGuide.Images.DrinkImage
alias CsGuide.Resources.{Brand, Drink}
alias CsGuide.Repo

data = [
  {"Heineken 0.0", "Heineken", "dcc93b04-da25-4b87-b7a1-655ea86b3582"},
  {"Becks Blue", "Becks", "cd222e86-fb33-4c9b-a76d-0349cf9f1028"},
  {"Lager", "Big Drop", "ad6302d3-52a2-40b2-adbd-0426640b0503"},
  {"Pale Ale", "Big Drop", "d4b0f34d-b225-4026-86f9-54343f1bc087"},
  {"Red Ale", "Big Drop", "e88f6319-69b4-4104-844e-9630d49ddd10"},
  {"Sour", "Big Drop", "8b1738fe-8cc7-430d-993e-834319951fab"},
  {"Spiced Ale", "Big Drop", "6155c83f-4d12-450f-9164-ca5f7a91a050"},
  {"Stout", "Big Drop", "ea7cc000-9c38-4080-a242-fc6c5b42ec76"},
  {"Drive Lager", "Bitburger", "968547a0-b18f-498e-bb13-308e355fc636"},
  {"Paloma Blend", "Borrago", "517f59b7-7e38-411c-81b4-bd2793215421"},
  {"Blush", "Botonique", "149517e7-152d-4272-a957-9cd5284879fb"},
  {"Original", "Botonique", "4279c33e-055c-44ce-a162-6f202fb7fc38"},
  {"Prohibition Brew ", "Budweiser", "29b68df1-ba22-4c2c-9871-4a4503843cfd"},
  {"Wild", "CEDER'S", "b2e15dc1-9640-4bd3-9d8a-adb9eacd7cc8"},
  {"Crisp", "CEDER'S", "3fa17901-3b6e-4200-8ca8-b2870f9ea4f9"},
  {"Classic", "CEDER'S", "340630c0-1e06-4d90-acff-6cd4efba2175"},
  {"Fitbeer", "FitBeer", "0b94b910-56f6-4e99-a55c-00b086bf7faf"},
  {"Premium Indian Tonic Water", "Fever-Tree", "c2e66777-189c-451f-9e3c-1d30564fdfa6"},
  {"Kosmic", "Nirvana Beer Co", "fb7e33fd-5823-41ed-916f-da940e7ffede"},
  {"T&E No.1", "Thomas & Evans", "d03c1f87-6ef1-44d5-b2c1-8a0d6e1b90fc"}
]

Enum.each(data, fn {name_drink, brand, id_image} ->
  b = Brand.get_by(name: brand)
  d = Repo.get_by!(Drink, name: name_drink, brand_id: b.id)
  Repo.insert!(%DrinkImage{entry_id: id_image, drink_id: d.id})
end)
