defmodule CsGuideWeb.BrandViewTest do
  use CsGuideWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import CsGuideWeb.BrandView

  @brand %{
    drinks: [
      %{
        venues: [
          %{cs_score: 1, venue_name: "venue1", venue_types: [%{name: "type1"}, %{name: "type2"}]},
          %{cs_score: 1, venue_name: "venue2", venue_types: [%{name: "type3"}, %{name: "type4"}]}
        ]
      },
      %{
        venues: [
          %{cs_score: 1, venue_name: "venue3", venue_types: [%{name: "type5"}, %{name: "type6"}]},
          %{cs_score: 1, venue_name: "venue4", venue_types: [%{name: "type7"}, %{name: "type8"}]}
        ]
      }
    ]
  }

  @venues [
    %CsGuide.Resources.Venue{
      venue_types: [%{name: "retailer"}]
    },
    %CsGuide.Resources.Venue{
      venue_types: [%{name: "wholesaler"}]
    },
    %CsGuide.Resources.Venue{
      venue_types: [%{name: "type1"}]
    }
  ]

  test "No venue type retail found" do
    assert  any_type?(@brand, "retail") == false
  end

  test "type3 found" do
    assert  any_type?(@brand, "type3") == true
  end

  test "retailers and wholesalers are filtered out" do
    assert filter_retailer_wholesaler(@venues) == [
             %CsGuide.Resources.Venue{
               venue_types: [%{name: "type1"}]
             }
           ]
  end
end
