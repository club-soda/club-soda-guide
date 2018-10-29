module Search exposing (..)

import Browser
import Http
import Json.Decode as Json exposing (..)
import Json.Decode.Pipeline exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Array exposing (..)


-- MODEL


type alias Drink =
    { name : String
    , brand : String
    , abv : Float
    , drink_types : List String
    , description : String
    }


type alias Model =
    { drinks : List Drink
    , dtype_filter : String
    , abv_filter : String
    }


type alias Flags =
    { dtype_filter : String
    }


type alias HttpData data =
    Result Http.Error data


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        dtype_filter =
            if flags.dtype_filter == "default" then
                ""
            else
                flags.dtype_filter
    in
        ( { drinks = []
          , dtype_filter = dtype_filter
          , abv_filter = ""
          }
        , getDrinks
        )


onChange : (String -> msg) -> Attribute msg
onChange msgConstructor =
    Html.Events.on "change" <| Json.map msgConstructor <| Json.at [ "target", "value" ] Json.string


getDrinks : Cmd Msg
getDrinks =
    Http.get ("/json_drinks") drinksDecoder |> Http.send ReceiveDrinks


drinksDecoder : Decoder (List Drink)
drinksDecoder =
    Json.list drinkDecoder


drinkDecoder : Decoder Drink
drinkDecoder =
    Json.map5 Drink
        (field "name" string)
        (field "brand" string)
        (field "abv" float)
        (field "drink_types" (Json.list string))
        (field "description" string)



-- UPDATE


type Msg
    = ReceiveDrinks (HttpData (List Drink))
    | SelectDrinkType String
    | SelectABVLevel String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            ( { model | drinks = drinks }, Cmd.none )

        SelectDrinkType drink_type ->
            ( { model | dtype_filter = drink_type }, Cmd.none )

        SelectABVLevel abv_level ->
            ( { model | abv_filter = abv_level }, Cmd.none )



-- VIEW


drink_types : List String
drink_types =
    [ "Beer", "Wine", "Spirits and Premixed", "Soft Drinks", "Flavoured Tonics", "Ciders" ]


abv_levels : List String
abv_levels =
    [ "0.05%", "0.5%", "1 - 2.5%", "2.5 - 8%" ]


view : Model -> Html Msg
view model =
    div [ class "mt6" ]
        [ div [ class "w-90 center" ]
            [ (renderFilter model "Drink Type" drink_types SelectDrinkType)
            , (renderFilter model "ABV" abv_levels SelectABVLevel)
            ]
        , div [ class "relative" ]
            [ div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
                (filterDrinks model)
            ]
        ]


filterDrinks : Model -> List (Html Msg)
filterDrinks model =
    List.filter (\d -> filterByType model d) model.drinks
        |> List.filter (\d -> filterByABV model d)
        |> renderDrinks


filterByABV : Model -> Drink -> Bool
filterByABV model drink =
    case model.abv_filter of
        "0.05%" ->
            drink.abv == 0.05

        "0.5%" ->
            drink.abv == 0.5

        "1 - 2.5%" ->
            (drink.abv >= 1 && drink.abv <= 2.5)

        "2.5 - 8%" ->
            (drink.abv >= 2.5 && drink.abv <= 8)

        _ ->
            True


filterByType : Model -> Drink -> Bool
filterByType model drink =
    case String.toLower model.dtype_filter of
        "spirits and premixed" ->
            List.any (\t -> ("spirit" == String.toLower t || "premixed" == String.toLower t)) drink.drink_types

        _ ->
            List.any (\t -> String.toLower model.dtype_filter == String.toLower t) drink.drink_types
                || model.dtype_filter
                == ""


renderDrinks : List Drink -> List (Html Msg)
renderDrinks drinks =
    if List.length drinks >= 1 then
        Array.fromList drinks
            |> Array.indexedMap
                (\index d ->
                    div
                        [ class "w-90 w-third-m w-20-l center-s shadow-4 br2 tr pb3 mh3 mv3 relative" ]
                        [ div [ class "card-front-contents" ]
                            [ div [ class "bb b--cs-light-pink bw3 mb3 tl h-27rem" ]
                                [ h4 [ class "f4 lh4 pa3 shadow-4 br2 mt4 mb1 tc bg-sheer-white absolute-horizontal-center top-1 w-80" ] [ text <| d.brand ++ " " ++ d.name ]
                                , img [ src "https://res.cloudinary.com/ratebeer/image/upload/w_250,c_limit/beer_117796.jpg", alt "Photo of drink", class "w-5rem db center pt4" ] []
                                , p [ class "bg-cs-mint br2 ph3 pv2 white shadow-4 ml4 mv4 dib" ] [ text <| String.fromFloat d.abv ++ "% ABV" ]
                                ]
                            ]
                        , input [ type_ "checkbox", name "card-front", id <| "display-back-" ++ String.fromInt index, class "display-back dn" ] []
                        , label [ for <| "display-back-" ++ String.fromInt index, class "cs-mid-blue f5 lh5 tr pr4 underline" ] []
                        , div [ class "card-back-contents dn absolute top-0 left-0 bg-white pt3 ph3" ]
                            [ div [ class "tl h-25rem" ]
                                [ div [ class "bb b--pink mt2 mh2 pb3 center" ]
                                    [ h4 [ class "f4 lh4 mb1" ] [ text d.name ]
                                    , p [ class "f5 lh5 mv1" ] [ text "by" ]
                                    , a [ class "f4 lh4 cs-mid-blue mv1", href "#" ] [ text d.brand ]
                                    ]
                                , div [ class "flex flex-wrap" ]
                                    [ p [ class "w-50 pv2 dib" ] [ text "Drink Category" ]
                                    , p [ class "w-50 pv2 dib" ] [ text <| String.fromFloat d.abv ++ "% ABV" ]
                                    ]
                                , p [ class "pv2" ]
                                    [ text d.description
                                    ]
                                ]
                            ]
                        ]
                )
            |> toList
    else
        [ div []
            [ p [] [ text "Your search didn't return any drinks, change your filters and try again." ]
            ]
        ]


renderFilter : Model -> String -> List String -> (String -> Msg) -> Html Msg
renderFilter model defaultTitle dropdownItems msgConstructor =
    div [ class "dib pr2" ]
        [ select
            [ onChange msgConstructor
            , class "f6 lh6 cs-light-gray bg-white b--cs-light-gray br2 bw1 pv2 pl3 dib w6"
            ]
            ([ option [ Html.Attributes.value "" ] [ text defaultTitle ] ]
                ++ List.map (\dropdownItem -> renderDropdownItems model dropdownItem) dropdownItems
            )
        ]


renderDropdownItems : Model -> String -> Html Msg
renderDropdownItems model dropdownItem =
    if (String.toLower dropdownItem) == (String.toLower model.dtype_filter) then
        option [ Html.Attributes.value dropdownItem, Html.Attributes.selected True ]
            [ text dropdownItem ]
    else
        option [ Html.Attributes.value dropdownItem ] [ text dropdownItem ]



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
