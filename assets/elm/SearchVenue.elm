module SearchVenue exposing (..)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import SharedTypes exposing (Venue)
import Json.Decode as Json exposing (..)
import Search exposing (..)


type alias Model =
    { venues : List Venue, filterType : Maybe String, filterScore : Maybe Float, filterName : Maybe String }


type alias Flags =
    { venues : List Venue }


type Msg
    = None
    | FilterVenueType String
    | FilterVenueScore String
    | FilterVenueName String


onChange : (String -> msg) -> Attribute msg
onChange msgConstructor =
    Html.Events.on "change" <| Json.map msgConstructor <| Json.at [ "target", "value" ] Json.string


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.venues Nothing Nothing Nothing, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        FilterVenueType venueType ->
            let
                filterType =
                    case venueType of
                        "" ->
                            Nothing

                        _ ->
                            Just venueType
            in
                ( { model | filterType = filterType }, Cmd.none )

        FilterVenueScore venueScore ->
            ( { model | filterScore = String.toFloat venueScore }, Cmd.none )

        FilterVenueName name ->
            let
                filterName =
                    case name of
                        "" ->
                            Nothing

                        _ ->
                            Just name
            in
                ( { model | filterName = filterName }, Cmd.none )


venue_types : List String
venue_types =
    [ "Hotels", "Pubs", "Restaurants", "Bars", "Cafes" ]


cs_score : List String
cs_score =
    [ "0", "0.5", "1", "1.5", "2", "2.5", "3", "3.5", "4", "4.5", "5" ]


view : Model -> Html Msg
view model =
    div [ class "mt5 mt6-ns" ]
        [ div [ class "w-90 center" ]
            [ (renderSearch "Search Venues..." FilterVenueName)
            , (renderFilter "Venue Type" venue_types FilterVenueType (Maybe.withDefault "" model.filterType))
            , (renderFilter "Club Soda Score" cs_score FilterVenueScore (case model.filterScore of
              Just score -> String.fromFloat score
              Nothing -> ""
              )
            )
            ]
        , div [ class "w-90 center" ]
            [ div []
                (renderVenues <| filterVenues model)
            ]
        ]


filterVenues : Model -> List Venue
filterVenues model =
    model.venues
        |> filterByName model.filterName
        |> filterByType model.filterType
        |> filterByScore model.filterScore


filterByName : Maybe String -> List Venue -> List Venue
filterByName searchTerm venues =
    case searchTerm of
        Nothing ->
            venues

        Just st ->
            List.filter (\v -> String.contains (String.toLower st) (String.toLower v.name)) venues


filterByType : Maybe String -> List Venue -> List Venue
filterByType typeVenue venues =
    case typeVenue of
        Nothing ->
            venues

        Just t ->
            List.filter (\v -> List.member t v.types) venues


filterByScore : Maybe Float -> List Venue -> List Venue
filterByScore score venues =
    case score of
        Nothing ->
            venues

        Just s ->
            List.filter (\v -> v.cs_score == s) venues


renderVenues : List Venue -> List (Html Msg)
renderVenues venues =
    if List.isEmpty venues then
        [ div [class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns"]
            [ p [ class "tc"] [ text "Your search didn't return any venues, change your filters and try again." ]
            ]
        ]
    else
        [ div [ class "flex flex-wrap justify-center pt3" ]
            (List.map venueCard venues)
        ]


venueCard : Venue -> Html Msg
venueCard venue =
    div [ class "w-100 w-25-ns pb4" ]
        [ a [ href <| "/venues/" ++ venue.id, class "cs-black no-underline pointer" ]
            [ if String.isEmpty venue.image then
                div [ class "bg-green w-100 w-90-m w5-l h4 br2 mb2 bg-venue-card" ] []
              else
                div [ class "bg-green w-100 w-90-m w5-l h4 br2 mb2 bg-venue-card", (style "background-image" ("url(" ++ venue.image ++ ")")) ] []
            , span [ class "f4 lh5 cs-black no-underline" ] [ text venue.name ]
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


main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
