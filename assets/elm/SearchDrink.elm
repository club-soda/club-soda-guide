module SearchDrink exposing (main)

import Array
import Browser
import Criteria
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Search exposing (renderFilter, renderSearch)
import Set
import SharedTypes exposing (Drink)
import TypeAndStyle
    exposing
        ( Filter
        , FilterType
        , SubFilters(..)
        , drinksTypeAndStyle
        , getFilterById
        , getFilterId
        , getFilterName
        , getFilterType
        )



-- MODEL


type alias Model =
    { drinks : List Drink
    , drink_filters : Criteria.State
    , abv_filter : String
    , search_term : String
    }


type alias Flags =
    { drinks : List Drink
    , dtype_filter : String
    , term : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        dtype_filter =
            if flags.dtype_filter == "default" then
                ""

            else
                flags.dtype_filter
    in
    ( { drinks = flags.drinks
      , drink_filters = Criteria.init
      , abv_filter = ""
      , search_term = flags.term
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SelectABVLevel String
    | SearchDrink String
    | UpdateFilters Criteria.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectABVLevel abv_level ->
            ( { model | abv_filter = abv_level }, Cmd.none )

        SearchDrink term ->
            ( { model | search_term = term }, Cmd.none )

        UpdateFilters state ->
            ( { model | drink_filters = state }, Cmd.none )



-- VIEW


getSubFilters : Filter -> List Filter
getSubFilters ( _, _, SubFilters subFilters ) =
    subFilters


criteriaConfig : Criteria.Config Msg Filter
criteriaConfig =
    let
        defaulCustomisations =
            Criteria.defaultCustomisations
    in
    Criteria.customConfig
        { title = "Drink Type"
        , toMsg = UpdateFilters
        , toId = getFilterId
        , toString = getFilterName
        , getSubFilters = getSubFilters
        , customisations =
            { defaulCustomisations
                | mainDivAttrs = mainDivAttrs
                , filtersDivAttrs = filtersDivAttrs
                , buttonAttrs = buttonAttrs
                , filterLabelAttrs = filterLabelAttrs
            }
        }


mainDivAttrs : List (Attribute Msg)
mainDivAttrs =
    [ class "relative bg-white dib z-max" ]


filtersDivAttrs : List (Attribute Msg)
filtersDivAttrs =
    [ class "absolute w100 ba bw1" ]


buttonAttrs : List (Attribute Msg)
buttonAttrs =
    [ class "f6 lh6 bg-white b--cs-gray br2 bw1 pv2 ph3 dib w6 cs-gray mr2" ]


filterLabelAttrs : Filter -> Criteria.State -> List (Attribute Msg)
filterLabelAttrs filter stateCriteria =
    [ class "pa2 pointer" ]


abv_levels : List String
abv_levels =
    [ "<0.05%", "0.05% - 0.5%", "0.51% - 1%", "1.1% - 3%", "3.1% +" ]


view : Model -> Html Msg
view model =
    div [ class "mt5 mt6-ns" ]
        [ div [ class "w-90 center" ]
            [ renderSearch "Search Drinks..." model.search_term SearchDrink
            , Criteria.view criteriaConfig model.drink_filters drinksTypeAndStyle
            , renderFilter "ABV" abv_levels SelectABVLevel model.abv_filter
            ]
        , div [ class "relative center w-90" ]
            [ div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
                (filterDrinks model)
            ]
        ]


filterDrinks : Model -> List (Html Msg)
filterDrinks model =
    model.drinks
        |> List.filter (\d -> filterByTypeAndStyle (Set.toList <| Criteria.selectedIdFilters model.drink_filters) d)
        |> List.filter (\d -> filterByABV model d)
        |> List.filter (\d -> filterByTerm model d)
        |> renderDrinks


filterByABV : Model -> Drink -> Bool
filterByABV model drink =
    case model.abv_filter of
        "<0.05%" ->
            drink.abv < 0.05

        "0.05% - 0.5%" ->
            drink.abv >= 0.05 && drink.abv <= 0.5

        "0.51% - 1%" ->
            drink.abv >= 0.51 && drink.abv <= 1

        "1.1% - 3%" ->
            drink.abv >= 1.1 && drink.abv <= 3

        "3.1% +" ->
            drink.abv > 3

        _ ->
            True


filterByTypeAndStyle : List String -> Drink -> Bool
filterByTypeAndStyle filters drink =
    case filters of
        [] ->
            True

        _ ->
            filters
                |> List.map
                    (\f ->
                        case getFilterById f drinksTypeAndStyle of
                            Nothing ->
                                False

                            Just ( TypeAndStyle.Type, _, _ ) ->
                                List.member f drink.drink_types

                            Just ( TypeAndStyle.Style, _, _ ) ->
                                List.member f drink.drink_styles
                    )
                |> List.any ((==) True)


filterByTerm : Model -> Drink -> Bool
filterByTerm model drink =
    case model.search_term of
        "" ->
            True

        term ->
            String.contains (String.toLower term) (String.toLower drink.name)
                || String.contains (String.toLower term) (String.toLower drink.description)


renderDrinks : List Drink -> List (Html Msg)
renderDrinks drinks =
    if List.length drinks >= 1 then
        Array.fromList drinks
            |> Array.indexedMap drinkCard
            |> Array.toList

    else
        [ div []
            [ p [ class "tc" ] [ text "Your search didn't return any drinks, change your filters and try again." ]
            ]
        ]



-- MAIN


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
