module SearchVenue exposing (Flags, Model, Msg(..), cs_score, filterByName, filterByScore, filterByType, filterVenues, init, main, onChange, update, venue_types, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (..)
import Search exposing (..)
import SharedTypes exposing (Venue)


type alias Model =
    { venues : List Venue, filterType : Maybe String, filterScore : Maybe Float, filterName : Maybe String }


type alias Flags =
    { venues : List Venue, term : String }


type Msg
    = FilterVenueType String
    | FilterVenueScore String
    | FilterVenueName String


onChange : (String -> msg) -> Attribute msg
onChange msgConstructor =
    Html.Events.on "change" <| Json.map msgConstructor <| Json.at [ "target", "value" ] Json.string


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        searchTerm =
            if String.isEmpty flags.term then
                Nothing

            else
                Just flags.term
    in
    ( Model flags.venues Nothing Nothing searchTerm, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
            [ renderSearch "Search Venues..." (Maybe.withDefault "" model.filterName) FilterVenueName
            , renderFilter "Venue Type" venue_types FilterVenueType (Maybe.withDefault "" model.filterType)
            , renderFilter "Club Soda Score"
                cs_score
                FilterVenueScore
                (model.filterScore
                    |> Maybe.map String.fromFloat
                    |> Maybe.withDefault ""
                )
            ]
        , div [ class "w-90 center" ]
            [ div []
                (Search.renderVenues <| filterVenues model)
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
    List.filter (SharedTypes.searchVenueByTerm searchTerm) venues


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


main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }
