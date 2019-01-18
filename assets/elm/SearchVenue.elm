module SearchVenue exposing (view)

import Browser
import Browser.Dom as Dom
import Browser.Events as Events
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Search exposing (..)
import SharedTypes exposing (Venue)
import Task


type alias Model =
    { venues : List Venue
    , filterType : Maybe String
    , filterScore : Maybe Float
    , filterName : Maybe String
    , venueTypes : List String
    , postcode : String
    , locationSearch : Bool
    }


type alias Flags =
    { venues : List Venue
    , term : String
    , venueTypes : List String
    , postcode : String
    , locationSearch : Bool
    }


type Msg
    = FilterVenueType String
    | FilterVenueScore String
    | FilterVenueName String
    | KeyDowns String
    | NoOp


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        searchTerm =
            if String.isEmpty flags.term then
                Nothing

            else
                Just flags.term
    in
    ( Model flags.venues Nothing Nothing searchTerm flags.venueTypes flags.postcode flags.locationSearch, Cmd.none )


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

        KeyDowns k ->
            if k == "Enter" then
                ( model, Task.attempt (\_ -> NoOp) (Dom.blur "search-input") )

            else
                ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


cs_score : List String
cs_score =
    [ "0", "1", "2", "3", "4", "5" ]


view : Model -> Html Msg
view model =
    div [ class "mt5 mt6-ns" ]
        [ renderLocationSearchTitle ( model.locationSearch, model.postcode )
        , div [ class "w-90 center" ]
            [ renderSearch "Search Venues..." (Maybe.withDefault "" model.filterName) FilterVenueName
            , renderFilter "Venue Type" model.venueTypes FilterVenueType (Maybe.withDefault "" model.filterType)
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


renderLocationSearchTitle : ( Bool, String ) -> Html Msg
renderLocationSearchTitle searchType =
    case searchType of
        ( True, "" ) ->
            h2 [ class "w-90 center tc" ] [ text "Venues near me" ]

        ( True, postcode ) ->
            h2 [ class "w-90 center tc" ] [ text ("Venues near " ++ postcode) ]

        _ ->
            text ""


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Events.onKeyDown (Decode.map KeyDowns Search.keyDecoder)


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
