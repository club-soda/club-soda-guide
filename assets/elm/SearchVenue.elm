port module SearchVenue exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Events as Events
import Criteria
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Search exposing (..)
import Set
import SharedTypes exposing (Venue)
import Task
import VenueScore exposing (..)


type alias Model =
    { venues : List Venue
    , filterType : Maybe String
    , filterScore : Criteria.State
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
    | UpdateVenueScore Criteria.State
    | UnselectVenueScore IdVenueScore
    | CloseVenueScoreDropdown Bool
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
    ( { venues = flags.venues
      , filterType = Nothing
      , filterScore = Criteria.init []
      , filterName = searchTerm
      , venueTypes = flags.venueTypes
      , postcode = flags.postcode
      , locationSearch = flags.locationSearch
      }
    , Cmd.none
    )


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

        UpdateVenueScore state ->
            ( { model | filterScore = state }, Cmd.none )

        UnselectVenueScore filterId ->
            let
                filterState =
                    Criteria.unselectFilter filterId model.filterScore
            in
            ( { model | filterScore = filterState }, Cmd.none )

        CloseVenueScoreDropdown close ->
            let
                filterScore =
                    if close then
                        Criteria.closeFilters model.filterScore

                    else
                        model.filterScore
            in
            ( { model | filterScore = filterScore }, Cmd.none )

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


view : Model -> Html Msg
view model =
    let
        venueScorePills =
            Set.toList (Criteria.selectedIdFilters model.filterScore)
                |> List.map (\f -> VenueScore.getVenueScoreFitlerById f VenueScore.venueScoreFilters)
    in
    div [ class "mt5 mt6-ns center mw-1500px" ]
        [ div [ class "w-90 center pl2-ns" ]
            [ renderSearch "Search Venues..." (Maybe.withDefault "" model.filterName) FilterVenueName
            , renderLocationSearchTitle ( model.locationSearch, model.postcode )
            , div []
                [ div [ classList [ ( "mb3", not (List.isEmpty venueScorePills) ) ] ] <|
                    List.map renderVenuseScorePills venueScorePills
                , renderFilter "Venue Type" model.venueTypes FilterVenueType (Maybe.withDefault "" model.filterType)
                , Criteria.view venueScoreConfig model.filterScore VenueScore.venueScoreFilters
                ]
            ]
        , div [ class "w-90 center" ]
            [ div []
                (Search.renderVenues <| filterVenues model)
            ]
        ]


renderVenuseScorePills : Maybe VenueScore.VenueScoreFilter -> Html Msg
renderVenuseScorePills filter =
    let
        filterName =
            case filter of
                Just f ->
                    VenueScore.getVenueScoreFilterName f

                Nothing ->
                    ""

        filterId =
            case filter of
                Just f ->
                    VenueScore.getVenueScoreFilterId f

                Nothing ->
                    ""
    in
    div [ class "ma1 dib pa2 br4 bg-cs-pink white", id "pill-venue-score" ]
        [ span [ class "pr1" ] [ text filterName ]
        , span [ class "pointer pl3 b", onClick (UnselectVenueScore filterId) ] [ text "x" ]
        ]



-- Config Criteria


venueScoreConfig : Criteria.Config Msg VenueScoreFilter
venueScoreConfig =
    let
        defaulCustomisations =
            Criteria.defaultCustomisations
    in
    Criteria.customConfig
        { title = "Club Soda Score"
        , toMsg = UpdateVenueScore
        , toId = VenueScore.getVenueScoreFilterId
        , toString = VenueScore.getVenueScoreFilterName
        , getSubFilters = \_ -> []
        , customisations =
            { defaulCustomisations
                | mainDivAttrs = mainDivAttrs
                , filtersDivAttrs = filtersDivAttrs
                , filterDivAttrs = filterDivAttrs
                , buttonAttrs = buttonAttrs
                , filterLabelAttrs = filterLabelAttrs
                , filterNameAttrs = filterNameAttrs
                , filterImgToggleAttrs = filterImgToggleAttrs
            }
        }


mainDivAttrs : List (Attribute Msg)
mainDivAttrs =
    [ class "relative bg-white dib z-1", id "dropdown-venue-score" ]



-- abvMainDivAttrs : List (Attribute Msg)
-- abvMainDivAttrs =
--     [ class "relative bg-white dib z-1", id "dropdown-abv" ]


filtersDivAttrs : List (Attribute Msg)
filtersDivAttrs =
    [ class "absolute w-200 bg-white shadow-1 bw1 dropdown" ]


filterDivAttrs : f -> Criteria.State -> List (Attribute Msg)
filterDivAttrs _ _ =
    [ style "padding" "0.5rem 0" ]


buttonAttrs : List (Attribute Msg)
buttonAttrs =
    [ class "f6 lh6 bg-white b--cs-gray br2 bw1 pv2 ph3 dib w6 cs-gray mr2 pointer" ]


filterLabelAttrs : f -> Criteria.State -> List (Attribute Msg)
filterLabelAttrs filter stateCriteria =
    [ class "pl2 pointer lh5 f5" ]


filterNameAttrs : f -> Criteria.State -> List (Attribute Msg)
filterNameAttrs _ _ =
    [ style "margin-left" "1rem" ]


filterImgToggleAttrs : List (Attribute Msg)
filterImgToggleAttrs =
    [ class "fr pointer", style "padding-right" "0.5rem" ]


renderLocationSearchTitle : ( Bool, String ) -> Html Msg
renderLocationSearchTitle searchType =
    case searchType of
        ( True, "" ) ->
            h2 [ class "dib pl4 pv3 f5 lh5" ] [ text "Displaying venues near me" ]

        ( True, postcode ) ->
            h2 [ class "dib pl4 pv3 f5 lh5" ] [ text ("Displaying venues near " ++ postcode) ]

        _ ->
            text ""


filterVenues : Model -> List Venue
filterVenues model =
    model.venues
        |> filterByName model.filterName
        |> filterByType model.filterType
        |> List.filter (\v -> filterScores (Set.toList <| Criteria.selectedIdFilters model.filterScore) v)


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


filterScores : List VenueScore.IdVenueScore -> Venue -> Bool
filterScores filters venue =
    case filters of
        [] ->
            True

        _ ->
            filters
                |> List.map (\f -> filterByScore f venue)
                |> List.any (\f -> f == True)


filterByScore : VenueScore.IdVenueScore -> Venue -> Bool
filterByScore score venue =
    let
        score_venue =
            String.toFloat score
    in
    case score_venue of
        Just s ->
            venue.cs_score == s || venue.cs_score == (s + 0.5)

        _ ->
            True


port closeVenueScoreDropdown : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ closeVenueScoreDropdown CloseVenueScoreDropdown
        , Events.onKeyDown (Decode.map KeyDowns Search.keyDecoder)
        ]


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
