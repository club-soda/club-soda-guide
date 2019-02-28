defmodule CsGuideWeb.BrandViewTest do
  use CsGuideWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import CsGuideWeb.BrandView

  @brand %{
    drinks: [
      %{
        venues: [
          %{cs_score: 1, venue_name: "venue1", venue_types: [%{name: "type1"}, %{name: "type2"}]},
          %{
            cs_score: 1,
            venue_name: "venue2",
            venue_types: [%{name: "retailer"}, %{name: "type4"}]
          }
        ]
      },
      %{
        venues: [
          %{
            cs_score: 1,
            venue_name: "venue3",
            venue_types: [%{name: "retailer"}, %{name: "type6"}]
          },
          %{
            cs_score: 1,
            venue_name: "venue4",
            venue_types: [%{name: "wholesaler"}, %{name: "type8"}]
          }
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
    assert any_type?(@brand, "retail") == false
  end

  test "type2 found" do
    assert any_type?(@brand, "type2") == true
  end

  test "retailers and wholesalers are filtered out" do
    assert get_filtered_venues(@brand) == [
             %{
               cs_score: 1,
               venue_name: "venue1",
               venue_types: [%{name: "type1"}, %{name: "type2"}]
             }
           ]
  end

  test "get_venues_over_n filters correctly" do
    assert get_venues_over_n(@venues, 1) == [
             %CsGuide.Resources.Venue{
               venue_types: [%{name: "type1"}]
             },
             %CsGuide.Resources.Venue{
               venue_types: [%{name: "wholesaler"}]
             }
           ]
  end
end
