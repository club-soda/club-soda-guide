module Search exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (..)


renderFilter : String -> List String -> (String -> msg) -> String -> Html msg
renderFilter defaultTitle dropdownItems msgConstructor selected =
    div [ class "dib pr2" ]
        [ select
            [ onChange msgConstructor
            , class "f6 lh6 bg-white b--cs-gray br2 bw1 pv2 ph3 dib w6"
            , classList [("cs-gray", ( selected == "" ))]
            ]
            ([ option [ Html.Attributes.value "" ] [ text defaultTitle ] ]
                ++ List.map (\dropdownItem -> renderDropdownItems dropdownItem) dropdownItems
            )
        ]


renderDropdownItems : String -> Html msg
renderDropdownItems dropdownItem =
    option [ Html.Attributes.value dropdownItem ] [ text dropdownItem ]


renderSearch : String -> (String -> msg) -> Html msg
renderSearch text msg =
    div [ class "db mb3 w-50" ]
        [ input
            [ type_ "text"
            , placeholder text
            , onInput msg
            , class "f6 lh6 cs-black bg-white ba b--cs-light-gray br2 pv2 pl3 pr6"
            ]
            []
        ]


onChange : (String -> msg) -> Attribute msg
onChange msgConstructor =
    Html.Events.on "change" <| Json.map msgConstructor <| Json.at [ "target", "value" ] Json.string
