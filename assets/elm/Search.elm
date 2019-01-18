module Search exposing (getScore, keyDecoder, onChange, renderDropdownItems, renderFilter, renderSearch, renderVenues, venueCard)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (at, field, map, string)
import SharedTypes exposing (..)


renderFilter : String -> List String -> (String -> msg) -> String -> Html msg
renderFilter defaultTitle dropdownItems msgConstructor selected =
    div [ class "dib pr2" ]
        [ select
            [ onChange msgConstructor
            , class "f6 lh6 bg-white b--cs-gray br2 bw1 pv2 ph3 dib w6 pointer"
            , classList [ ( "cs-gray", selected == "" ) ]
            ]
            ([ option [ Html.Attributes.value "" ] [ text defaultTitle ] ]
                ++ List.map (\dropdownItem -> renderDropdownItems dropdownItem) dropdownItems
            )
        ]


renderDropdownItems : String -> Html msg
renderDropdownItems dropdownItem =
    option [ Html.Attributes.value dropdownItem ] [ text dropdownItem ]


renderSearch : String -> String -> (String -> msg) -> Html msg
renderSearch text inputValue msg =
    div [ class "db mb3 w-50" ]
        [ input
            [ type_ "search"
            , placeholder text
            , onInput msg
            , class "f6 lh6 cs-black bg-white ba b--cs-light-gray br2 pv2 pl3 w-15rem"
            , value inputValue
            , id "search-input"
            ]
            []
        ]


onChange : (String -> msg) -> Attribute msg
onChange msgConstructor =
    Html.Events.on "change" <| Json.map msgConstructor <| Json.at [ "target", "value" ] Json.string



-- VIEW CARDS


renderVenues : List Venue -> List (Html msg)
renderVenues venues =
    if List.isEmpty venues then
        [ div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
            [ p [ class "tc" ] [ text "Your search didn't return any venues, change your filters and try again." ]
            ]
        ]

    else
        [ div [ class "flex flex-wrap justify-center pt3" ]
            (List.map venueCard venues)
        ]


venueCard : Venue -> Html msg
venueCard venue =
    div [ class "w-100 w-25-ns pb4" ]
        [ a [ href <| "/venues/" ++ venue.slug, class "cs-black no-underline pointer" ]
            [ if String.isEmpty venue.image then
                div [ class "bg-light-gray w-100 w-90-m w5-l h4 br2 mb2 bg-venue-card", style "background-image" "url('/images/default-venue-img-2-1.jpg')" ] []

              else
                div [ class "bg-light-gray w-100 w-90-m w5-l h4 br2 mb2 bg-venue-card", style "background-image" ("url(" ++ venue.image ++ ")") ] []
            , span [ class "f4 lh5 cs-black no-underline" ] [ text venue.name ]
            , p [ class "f5 lh5" ] [ text venue.city ]
            , p [ class "f5 lh5" ] [ text venue.postcode ]
            , p [] [ text <| String.join ", " venue.types ]
            , if venue.cs_score > 0.0 then
                div [ class "pt2" ]
                    [ img [ class "w4 v-btm", src <| "/images/score-" ++ getScore venue.cs_score ++ ".png", alt <| "club soda score of " ++ String.fromFloat venue.cs_score ] [] ]

              else
                div [ class "pt2" ] []
            ]
        ]


getScore : Float -> String
getScore score =
    let
        s =
            String.fromFloat score
    in
    if String.length s == 1 then
        s ++ ".0"

    else
        s


keyDecoder : Json.Decoder String
keyDecoder =
    Json.field "key" Json.string
