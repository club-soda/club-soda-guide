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

File.read!("/Users/Daniel/Desktop/Brands Table-Grid view.csv") |> CsGuide.Import.brands()
File.read!("/Users/Daniel/Desktop/Products-Grid view.csv") |> CsGuide.Import.drinks()

File.read!("/Users/Daniel/Desktop/gd_place_2210181445\ -\ gd_place_2210181445.csv")
|> CsGuide.Import.venues_1()

File.read!("/Users/Daniel/Desktop/wpcsv-export-20181022144224 - wpcsv-export-20181022144224.csv")
|> CsGuide.Import.venues_2()
