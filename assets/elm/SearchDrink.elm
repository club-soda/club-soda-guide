port module SearchDrink exposing (main)

import Abv exposing (..)
import Array
import Browser
import Browser.Dom as Dom
import Browser.Events as Events
import Criteria
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Search exposing (keyDecoder, renderFilter, renderSearch)
import Set
import SharedTypes exposing (Drink)
import Task
import TypeAndStyle
    exposing
        ( Filter
        , FilterId
        , FilterType
        , SubFilters(..)
        , TypesAndStyles
        , filterParentTypes
        , getDrinkTypesAndStyles
        , getFilterById
        , getFilterId
        , getFilterName
        , getFilterType
        )



-- MODEL


type alias Model =
    { drinks : List Drink
    , drinkFilters : Criteria.State
    , abvFilter : Criteria.State
    , searchTerm : Maybe String
    , typesAndStyles : List Filter
    , drinksToDisplay : Int
    }


type alias Flags =
    { drinks : List Drink
    , dtype_filter : String
    , term : String
    , types_styles : List TypesAndStyles
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        filters =
            getDrinkTypesAndStyles flags.types_styles

        dtype_filter =
            if flags.dtype_filter == "none" then
                []

            else
                case getFilterById ("type-" ++ flags.dtype_filter) filters of
                    Nothing ->
                        []

                    Just _ ->
                        [ "type-" ++ flags.dtype_filter ]
    in
    ( { drinks = flags.drinks
      , drinkFilters = Criteria.init dtype_filter
      , drinksToDisplay = defaultDrinksToDisplay
      , abvFilter = Criteria.init []
      , searchTerm =
            if String.isEmpty flags.term then
                Nothing

            else
                Just flags.term
      , typesAndStyles = filters
      }
    , Cmd.none
    )


defaultDrinksToDisplay : Int
defaultDrinksToDisplay =
    40



-- UPDATE


type Msg
    = SearchDrink String
    | UpdateFilters Criteria.State
    | UpdateAbv Criteria.State
    | UnselectFilter FilterId
    | UnselectAbvFilter FilterId
    | CloseDropdown Bool
    | CloseAbvDropdown Bool
    | KeyDowns String
    | NoOp
    | ScrolledToBottom Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchDrink term ->
            let
                searchTerm =
                    if String.isEmpty term then
                        Nothing

                    else
                        Just term
            in
            ( { model | searchTerm = searchTerm, drinksToDisplay = defaultDrinksToDisplay }, Cmd.none )

        UpdateAbv abvState ->
            ( { model | abvFilter = abvState, drinksToDisplay = defaultDrinksToDisplay }, Cmd.none )

        UpdateFilters state ->
            ( { model | drinkFilters = state, drinksToDisplay = defaultDrinksToDisplay }, Cmd.none )

        UnselectFilter filterId ->
            let
                filterState =
                    Criteria.unselectFilter filterId model.drinkFilters
            in
            ( { model | drinkFilters = filterState, drinksToDisplay = defaultDrinksToDisplay }, Cmd.none )

        UnselectAbvFilter filterId ->
            let
                filterState =
                    Criteria.unselectFilter filterId model.abvFilter
            in
            ( { model | abvFilter = filterState, drinksToDisplay = defaultDrinksToDisplay }, Cmd.none )

        CloseDropdown close ->
            let
                drinkFilters =
                    if close then
                        Criteria.closeFilters model.drinkFilters

                    else
                        model.drinkFilters
            in
            ( { model | drinkFilters = drinkFilters }, Cmd.none )

        CloseAbvDropdown close ->
            let
                abvFilter =
                    if close then
                        Criteria.closeFilters model.abvFilter

                    else
                        model.abvFilter
            in
            ( { model | abvFilter = abvFilter }, Cmd.none )

        KeyDowns k ->
            if k == "Enter" then
                ( model, Task.attempt (\_ -> NoOp) (Dom.blur "search-input") )

            else
                ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        ScrolledToBottom pos ->
            ( { model | drinksToDisplay = model.drinksToDisplay + defaultDrinksToDisplay }, Cmd.none )



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
                , filterDivAttrs = filterDivAttrs
                , buttonAttrs = buttonAttrs
                , filterLabelAttrs = filterLabelAttrs
                , filterNameAttrs = filterNameAttrs
                , filterImgToggleAttrs = filterImgToggleAttrs
            }
        }


abvConfig : Criteria.Config Msg AbvFilter
abvConfig =
    let
        defaulCustomisations =
            Criteria.defaultCustomisations
    in
    Criteria.customConfig
        { title = "ABV"
        , toMsg = UpdateAbv
        , toId = getAbvFilterId
        , toString = getAbvFilterName
        , getSubFilters = \_ -> []
        , customisations =
            { defaulCustomisations
                | mainDivAttrs = abvMainDivAttrs
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
    [ class "relative bg-white dib z-1", id "dropdown-types-styles" ]


abvMainDivAttrs : List (Attribute Msg)
abvMainDivAttrs =
    [ class "relative bg-white dib z-1", id "dropdown-abv" ]


filtersDivAttrs : List (Attribute Msg)
filtersDivAttrs =
    [ class "absolute w-200 bg-white shadow-1 bw1 dropdown" ]


filterDivAttrs : f -> Criteria.State -> List (Attribute Msg)
filterDivAttrs _ _ =
    [ style "padding" "0.5rem 0" ]


buttonAttrs : Criteria.State -> List (Attribute Msg)
buttonAttrs stateCriteria =
    if Criteria.isOpen stateCriteria then
        [ class "f6 lh6 br2 bw1 pv2 ph3 dib w6 mr2 pointer bg-cs-navy b--cs-navy white" ]

    else
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


view : Model -> Html Msg
view model =
    let
        typeAndStylePills =
            Set.toList (Criteria.selectedIdFilters model.drinkFilters)
                |> List.map (\f -> getFilterById f model.typesAndStyles)

        abvPills =
            Set.toList (Criteria.selectedIdFilters model.abvFilter)
                |> List.map (\f -> getAbvFilterById f Abv.abvFilters)
    in
    div [ class "mt5 mt6-ns center mw-1500px" ]
        [ div [ class "w-90 center pl2-ns" ]
            [ renderSearch "Search Drinks..." (Maybe.withDefault "" model.searchTerm) SearchDrink
            , div [ classList [ ( "mb3", not (List.isEmpty typeAndStylePills) ), ( "mb3", not (List.isEmpty abvPills) ) ] ] <|
                List.map renderPillFilter typeAndStylePills
                    ++ List.map renderPillAbv abvPills
            , Criteria.view criteriaConfig model.drinkFilters model.typesAndStyles
            , Criteria.view abvConfig model.abvFilter Abv.abvFilters
            , div [ class "relative center" ]
                [ div [ class "flex-ns flex-wrap pt3 pb4-ns db dib-ns" ]
                    (filterDrinks model)
                ]
            ]
        ]


renderPillAbv : Maybe Abv.AbvFilter -> Html Msg
renderPillAbv filter =
    let
        filterName =
            case filter of
                Just f ->
                    getAbvFilterName f

                Nothing ->
                    ""

        filterId =
            case filter of
                Just f ->
                    getAbvFilterId f

                Nothing ->
                    ""
    in
    div [ class "ma1 dib pa2 br4 bg-cs-pink white", id "pill-abv" ]
        [ span [ class "pr1" ] [ text filterName ]
        , span [ class "pointer pl3 b", onClick (UnselectAbvFilter filterId) ] [ text "x" ]
        ]


renderPillFilter : Maybe Filter -> Html Msg
renderPillFilter filter =
    let
        filterName =
            case filter of
                Just f ->
                    getFilterName f

                Nothing ->
                    ""

        filterId =
            case filter of
                Just f ->
                    getFilterId f

                Nothing ->
                    ""
    in
    div [ class "ma1 dib pa2 br4 bg-cs-pink white", id "pill-type-style" ]
        [ span [ class "pr1" ] [ text filterName ]
        , span [ class "pointer pl3 b", onClick (UnselectFilter filterId) ] [ text "x" ]
        ]


filterDrinks : Model -> List (Html Msg)
filterDrinks model =
    let
        selectedFitlerIds =
            Set.toList <| Criteria.selectedIdFilters model.drinkFilters
    in
    model.drinks
        |> List.filter
            (\d ->
                filterByTypeAndStyle
                    (List.filter (filterParentTypes model.typesAndStyles selectedFitlerIds)
                        selectedFitlerIds
                    )
                    d
                    model.typesAndStyles
            )
        |> List.filter (\d -> filterByABV (Set.toList <| Criteria.selectedIdFilters model.abvFilter) d)
        |> List.filter (\d -> SharedTypes.searchDrinkByTerm model.searchTerm d)
        |> List.take model.drinksToDisplay
        |> renderDrinks


filterByTypeAndStyle : List String -> Drink -> List Filter -> Bool
filterByTypeAndStyle filters drink typesAndStyles =
    case filters of
        [] ->
            True

        _ ->
            filters
                |> List.map
                    (\f ->
                        case getFilterById f typesAndStyles of
                            Nothing ->
                                False

                            Just ( TypeAndStyle.Type, filterName, _ ) ->
                                List.member filterName drink.drink_types

                            Just ( TypeAndStyle.Style, filterName, _ ) ->
                                List.member filterName drink.drink_styles
                    )
                |> List.any ((==) True)


filterByABV : List IdAbvFilter -> Drink -> Bool
filterByABV filters drink =
    case filters of
        [] ->
            True

        _ ->
            filters
                |> List.map (\f -> filterABV f drink)
                |> List.any (\f -> f == True)


filterABV : IdAbvFilter -> Drink -> Bool
filterABV abvFilter drink =
    case abvFilter of
        "0" ->
            drink.abv < 0.05

        "1" ->
            drink.abv >= 0.05 && drink.abv <= 0.5

        "2" ->
            drink.abv >= 0.51 && drink.abv <= 1

        "3" ->
            drink.abv >= 1.1 && drink.abv <= 3

        "4" ->
            drink.abv > 3

        _ ->
            True


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



-- Subscriptions


port scroll : (Bool -> msg) -> Sub msg


port closeDropdownTypeStyle : (Bool -> msg) -> Sub msg


port closeAbvDropdown : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ closeDropdownTypeStyle CloseDropdown
        , closeAbvDropdown CloseAbvDropdown
        , Events.onKeyDown (Decode.map KeyDowns Search.keyDecoder)
        , scroll ScrolledToBottom
        ]



-- MAIN


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
