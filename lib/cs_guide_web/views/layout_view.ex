defmodule CsGuideWeb.LayoutView do
  use CsGuideWeb, :view

  def change_spaces_to_dashes(str) do
    String.replace(str, " ", "-")
  end

  def meta_description(conn) do
    path = conn.request_path |> String.downcase()
    cond do
      path =~ "/search/drinks" ->
        "Search from over 750 low and no alcohol drinks, including wines, beers, and spirits"
      path =~ "/search/venues" ->
        "Find the best UK venues for low and no alcohol drinks near you and see what they stock"
      path =~ "/users/new" ->
        "Sign up your venue to the Club Soda Guide to get your Club Soda score and allow our members to start finding you."
      path =~ "/brands/heineken" -> # /brands/heineken
        "Heineken 0.0 is twice brewed and fermented with Heineken's unique A-yeast from natural ingredients with gentle alcohol removal and blending to achieve a fruity flavour and slight malty notes."
      path =~ "/brands/old-mout" ->
        "Old Mout Alcohol Free Berries & Cherries is a special blend of strawberry and raspberry with notes of blueberry."
      path =~ "/brands/punchy-drinks" ->
        "PUNCHY are an independent start up who make alcohol and non-alcoholic punch, and believe that whether you're drinking or not, you shouldn't have to miss out."
      path =~ "/brands/shrb" ->
        "/shrb... for the perfect non-alcoholic drink. The vinegar base gives it an alcohol-like kick, a rich flavour bouquet and very low sugar."
      path =~ "/brands/genie-living-drinks-co" ->
        "Genie Living Drinks produce delicious natural & vegan drinks that celebrate the brilliance of bacteria for a healthy gut."
      path =~ "/brands" ->
        "Search for the best low and no alcohol brands, including wines, beers, and spirits"
      path =~ "/contact" ->
        "Get in touch with us by email or on social media"
      path =~ "/about-us" ->
        "Club Soda is a mindful drinking movement of individuals, drinks, and venues."
      path =~ "/frequently-asked-questions" ->
        "Find out more about the Club Soda Guide, the UK’s first directory for low and no alcohol drinks, and how you can get involved."
      true ->
        "The Club Soda Guide is the UK’s first directory for low and no alcohol drinks, and the best places to find them."
    end
  end

  def page_title(nil), do: "Club Soda Guide"
  def page_title(static_page) do
    if String.trim(static_page.browser_title || "") == "" do
      "Club Soda Guide"
    else
      String.trim(static_page.browser_title)
    end
  end
end
