defmodule CsGuideWeb.ErrorViewTest do
  use CsGuideWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import CsGuideWeb.BrandView

  @brand  %{drinks: [
    %{venues:
        [ %{cs_score: 1, name: "venue1", venue_types: [%{name: "type1"}, %{name: "type2"}]},
          %{cs_score: 1, name: "venue2", venue_types: [%{name: "type3"}, %{name: "type4"}]}
        ]
    },
    %{venues:
        [ %{cs_score: 1, name: "venue3", venue_types: [%{name: "type5"}, %{name: "type6"}]},
          %{cs_score: 1, name: "venue4", venue_types: [%{name: "type7"}, %{name: "type8"}]}
        ]
    }
  ]
}


  test "No venue type retail found" do
    assert  any_type?(@brand, "retail") == false
  end

  test "type3 found" do
    assert  any_type?(@brand, "type3") == true
  end

end
