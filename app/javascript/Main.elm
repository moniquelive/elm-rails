module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D



-- MAIN


main : Program (Maybe {}) Model Msg
main =
    Browser.element
        { init = always init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Pokemon =
    { name : String
    , image : String
    }


type alias Model =
    { pokemons : List Pokemon
    , selectedPokemon : Pokemon
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model [] <| Pokemon "" "", getPokemons )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ pokemonDetail model.selectedPokemon
            , div [ class "col-8" ]
                (List.map (\c -> pokemonsThatStartWith c model.pokemons) <| String.split "" "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            ]
        ]


pokemonDetail : Pokemon -> Html Msg
pokemonDetail pokemon =
    div
        [ class "col-4"
        , style "height" "256px"
        , style "text-align" "center"
        ]
        [ img [ style "max-width" "128px", src pokemon.image ] []
        , h2 [] [ text pokemon.name ]
        ]


pokemonsThatStartWith : String -> List Pokemon -> Html Msg
pokemonsThatStartWith c pokemons =
    div []
        [ h2 [] [ text c ]
        , span []
            (List.filter (\p -> String.startsWith c p.name) pokemons
                |> List.map pokemonView
            )
        ]


pokemonView : Pokemon -> Html Msg
pokemonView pokemon =
    span []
        [ a [ onMouseOver (PokemonDetails pokemon) ]
            [ text pokemon.name ]
        , text " "
        ]



-- MESSAGE


type Msg
    = GotPokemons (Result Http.Error (List Pokemon))
    | PokemonDetails Pokemon



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        GotPokemons result ->
            case result of
                Ok pokemons ->
                    let
                        sorted =
                            List.sortBy .name pokemons
                    in
                    ( { model | pokemons = sorted }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        PokemonDetails pokemon ->
            ( { model | selectedPokemon = pokemon }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- HTTP


getPokemons : Cmd Msg
getPokemons =
    Http.get
        { url = "/pokemons.json"
        , expect = Http.expectJson GotPokemons pokemonsDecoder
        }


pokemonsDecoder : D.Decoder (List Pokemon)
pokemonsDecoder =
    D.list pokemonDecoder


pokemonDecoder : D.Decoder Pokemon
pokemonDecoder =
    D.map2 Pokemon
        (D.field "name" D.string)
        (D.field "image" D.string)
