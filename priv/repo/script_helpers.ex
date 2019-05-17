defmodule CsGuide.ScriptHelpers do
  alias NimbleCSV.RFC4180, as: CSV

  def venues do
    %{ # should this list be alphabetical?
      all_bar_one:
        ~w(venue_name nil address phone_number description website facebook twitter instagram nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11)a,
      yates:
        ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
      common_room:
        ~w(venue_name nil address phone_number email description website facebook twitter venue_types)a,
      town_and_pub:
        ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13)a,
      walkabout:
        ~w(venue_name nil address phone_number description website facebook twitter nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8)a,
      browns:
        ~w(venue_name nil address phone_number description website venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11)a,
      slug_and_lettuce:
        ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
      classic_inns:
        ~w(venue_name nil address phone_number email description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
      stonehouse:
        ~w(venue_name nil address phone_number description website facebook instagram twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4)a,
      miller_and_carter:
        ~w(venue_name nil address phone_number description website facebook twitter instagram venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14)a,
      ember_inns:
        ~w(venue_name nil address phone_number description website facebook venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12)a,
      oneills:
        ~w(venue_name nil address phone_number description website facebook twitter nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
      harvester:
        ~w(venue_name nil address phone_number description website facebook twitter instagram nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13)a,
      vintage_inns:
        ~w(venue_name nil address phone_number description website facebook twitter nil venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13)a,
      sizzling_pubs:
        ~w(venue_name nil address phone_number description website facebook twitter venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7)a,
      nicholsons:
        ~w(venue_name nil address phone_number description website facebook twitter instagram venue_types num_cocktails drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14 drink_15 drink_16 drink_17)a,
      bermondsey_pub_company:
        ~w(venue_name parent_company address city postcode phone_number venue_types email description website facebook twitter instagram drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14 drink_15 drink_16 drink_17 drink_18)a,
      craft_union:
        ~w(venue_name address city postcode venue_types parent_company website facebook twitter drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9)a,
      brewdog:
        ~w(venue_name venue_types parent_company address city postcode phone_number email description website facebook twitter instagram nil drink_1 drink_2 drink_3)a,
    }
  end

  def get_address_and_postcode(venue) do
    case extract_postcode(venue.address) do
      [_address] ->
        [venue.address, venue.postcode]
      list ->
        list
    end
  end

  # extract_postcode assumes address has postcode in-line
  def extract_postcode(str) do
    postcode_regex =
      ~r/((GIR 0AA)|((([A-PR-UWYZ][0-9][0-9]?)|(([A-PR-UWYZ][A-HK-Y][0-9][0-9]?)|(([A-PR-UWYZ][0-9][A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y][0-9][ABEHMNPRVWXY])))) [0-9][ABD-HJLNP-UW-Z]{2}))/

    Regex.split(postcode_regex, str, include_captures: true, trim: true)
  end

  def csv_to_list_of_maps(csv, columns) do
    csv
    |> CSV.parse_string()
    |> Enum.map(fn data ->
      columns
      |> Enum.zip(data)
      |> Enum.filter(fn {k, _v} -> not is_nil(k) end)
      |> Map.new()
    end)
  end
end
