module SearchAll exposing (main)

import Array exposing (..)
import Browser
import Browser.Dom as Dom
import Browser.Events as Events
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Json.Decode as Decode
import Search exposing (..)
import SharedTypes
import Task
import Url


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Events.onKeyDown (Decode.map KeyDowns Search.keyDecoder)



-- MODEL


type alias Model =
    { drinks : List SharedTypes.Drink
    , venues : List SharedTypes.Venue
    , term : Maybe String
    }


type alias Flags =
    { drinks : List SharedTypes.Drink
    , venues : List SharedTypes.Venue
    , term : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        term =
            if String.isEmpty flags.term then
                Nothing

            else
                Just flags.term
    in
    ( Model flags.drinks flags.venues term, Cmd.none )



-- Msg & UPDATE


type Msg
    = UpdateSearchTerm String
    | KeyDowns String
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchTerm term ->
            case term of
                "" ->
                    ( { model | term = Nothing }, Cmd.none )

                _ ->
                    ( { model | term = Just term }, Cmd.none )

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
        searchTerm =
            Maybe.withDefault "" model.term

        drinks =
            filterDrinks model.term model.drinks

        venues =
            filterVenues model.term model.venues

        totalDrinks =
            List.length drinks

        totalVenues =
            List.length venues
    in
    div [ class "mt5 mt6-ns center mw-1500px" ]
        [ div [ class "relative w-90 center pl2-ns" ]
            [ input
                [ class "f6 lh6 cs-black bg-search ba b--cs-light-gray br2 pv2 pr2 pl-2-5rem w-15rem"
                , id "search-input"
                , onInput UpdateSearchTerm
                , value searchTerm
                , placeholder "Search drinks and venues"
                , type_ "search"
                ]
                []
            , p [ class "pv3 f5 lh5 dib pl4-ns" ] [ text <| resultDescription totalDrinks totalVenues ]
            ]
        , div [ class "relative w-90 center pb5" ]
            [ h1 [ class "center b pt3 f2 lh2 pl2-ns" ] [ text "Drinks" ]
            , renderDrinks <| List.take 4 drinks
            , drinksPage totalDrinks 4 searchTerm
            , h1 [ class "center b pt5 f2 lh2 pl2-ns" ] [ text "Venues" ]
            , renderVenues <| List.take 4 venues
            , venuesPage totalVenues 4 searchTerm
            ]
        ]


drinksPage : Int -> Int -> String -> Html Msg
drinksPage totalDrinks drinksDisplayed searchTerm =
    if (totalDrinks - drinksDisplayed) <= 0 then
        a [ href <| "/search/drinks", class "bg-cs-black br2 ph4 pv2 white no-underline" ] [ text "View all drinks" ]

    else
        a [ href <| "/search/drinks?term=" ++ Url.percentEncode searchTerm, class "bg-cs-black br2 ph4 ml2-ns pv2 white no-underline" ] [ text <| "See all (" ++ String.fromInt totalDrinks ++ ")" ]


venuesPage : Int -> Int -> String -> Html Msg
venuesPage totalVenues venuesDisplayed searchTerm =
    if (totalVenues - venuesDisplayed) <= 0 then
        a [ href <| "/search/venues", class "bg-cs-black br2 ph4 pv2 white no-underline" ] [ text "View all venues" ]

    else
        a [ href <| "/search/venues?term=" ++ Url.percentEncode searchTerm, class "bg-cs-black br2 ph4 ml2-ns pv2 white no-underline" ] [ text <| "See all (" ++ String.fromInt totalVenues ++ ")" ]


resultDescription : Int -> Int -> String
resultDescription totalDrinks totalVenues =
    "Found "
        ++ (String.fromInt <| totalDrinks)
        ++ (if totalDrinks == 1 then
                " drink, "

            else
                " drinks, "
           )
        ++ (String.fromInt <| totalVenues)
        ++ (if totalVenues == 1 then
                " venue"

            else
                " venues"
           )


filterDrinks : Maybe String -> List SharedTypes.Drink -> List SharedTypes.Drink
filterDrinks searchTerm drinks =
    drinks
        |> List.filter (SharedTypes.searchDrinkByTerm searchTerm)


filterVenues : Maybe String -> List SharedTypes.Venue -> List SharedTypes.Venue
filterVenues searchTerm venues =
    venues
        |> List.filter (SharedTypes.searchVenueByTerm searchTerm)


renderDrinks : List SharedTypes.Drink -> Html Msg
renderDrinks drinks =
    case drinks of
        [] ->
            p [ class "pt3 h3" ] [ text "No drinks match the search term." ]

        _ ->
            div [ class "flex-ns flex-wrap pt3 pb4 db dib-ns" ]
                (Array.fromList drinks
                    |> Array.indexedMap drinkCard
                    |> toList
                )


renderVenues : List SharedTypes.Venue -> Html Msg
renderVenues venues =
    case venues of
        [] ->
            p [ class "pt3 h3" ] [ text "No venues match the search term." ]

        _ ->
            div [] (Search.renderVenues venues)
