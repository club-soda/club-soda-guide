module DrinksCarousel exposing (..)

import Browser
import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)


-- MAIN


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


getDrinks : Cmd Msg
getDrinks =
    Http.get ("/json_drinks") drinksDecoder |> Http.send ReceiveDrinks


drinksDecoder : Decoder (List Drink)
drinksDecoder =
    Decode.list drinkDecoder


drinkDecoder : Decoder Drink
drinkDecoder =
    Decode.map3 Drink
        (field "name" string)
        (field "brand" string)
        (field "abv" float)


type alias HttpData data =
    Result Http.Error data


type alias Drink =
    { name : String
    , brand : String
    , abv : Float
    }


type alias Model =
    { drinks : List Drink
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model []
    , getDrinks
    )



-- UPDATE


type Msg
    = ReceiveDrinks (HttpData (List Drink))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            let
                a =
                    Debug.log "drinks ok" "no"
            in
                ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            let
                a =
                    Debug.log "drinks ok" "yes"
            in
                ( { model | drinks = drinks }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "flex-ns flex-wrap justify-center pv4-ns" ]
        (List.indexedMap
            (\index d ->
                div
                    [ class "w-third-m w-20-l shadow-4 br2 tr pb3 mh3 mv3 relative" ]
                    [ div [ class "card-front-contents" ]
                        [ div [ class "bb b--cs-light-pink bw3 mb3 tl h-30rem" ]
                            [ h4 [ class "f4 lh4 pa3 shadow-4 br2 mt4 mb1 mh4 tc" ] [ text <| d.brand ++ " " ++ d.name ]
                            , img [ src "https://res.cloudinary.com/ratebeer/image/upload/w_250,c_limit/beer_117796.jpg", alt "Photo of drink", class "w-5rem db center" ] []
                            , p [ class "bg-cs-mint br2 ph3 pv2 white shadow-4 ml4 mv4 dib" ] [ text <| String.fromFloat d.abv ++ "% ABV" ]
                            ]
                        ]
                    , input [ type_ "checkbox", name "card-front", id <| "display-back-" ++ String.fromInt index, class "display-back dn" ] []
                    , label [ for <| "display-back-" ++ String.fromInt index, class "cs-mid-blue f5 lh5 tr pr4 underline" ] []
                    , div [ class "card-back-contents dn absolute top-0 left-0 bg-white pt3 ph3" ]
                        [ div [ class "mb3 tl h-30rem" ]
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
                                [ text "Drink description text Drink description \n                                text Drink description text Drink description \n                                text Drink description text"
                                ]
                            ]
                        ]
                    ]
            )
            model.drinks
        )
