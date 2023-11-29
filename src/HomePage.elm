-- Input a user name and password. Make sure the password matches.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/forms.html
--
port module HomePage exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
--import Stream exposing (..)


-- PORTS

port sendMessage : String -> Cmd msg
port receiveChunk : (String -> msg) -> Sub msg
port receiveStop : (String -> msg) -> Sub msg
port receiveDone : (String -> msg) -> Sub msg


-- MAIN

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model =
  { question : String,
    response: String
  }



init : () -> ( Model, Cmd Msg )
init flags =
  ( { question = "", response = "" }
  , Cmd.none
  )


-- UPDATE


type Msg
  = Send
  | QuestionChanged String
  | Recv String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    
    QuestionChanged q ->
      ( { model | question = q, response = q }
         , Cmd.none
      )

    Send ->
      ( { model | question = "", response = model.response ++ "<br>" ++ "Answer: " }
      , sendMessage model.question
      )

    Recv chunk ->
      ( { model | response = model.response ++ chunk }
      , Cmd.none
      )


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ viewQuestion "text" "What's up, Doc?" model.question QuestionChanged
    ,submitQuestion Send
    ,viewResponse model
    ]


viewQuestion : String -> String -> String -> (String -> Msg) -> Html Msg
viewQuestion t p v msg =
  input [ type_ t, placeholder p, value v, onInput msg] []

submitQuestion : Msg ->  Html Msg
submitQuestion msg =
    button [ onClick msg ] [ text "Submit"]

viewResponse : Model -> Html Msg
viewResponse model =
  div [ style "color" "black" ] [ text model.response ]



-- SUBSCRIPTIONS

-- From: https://ellie-app.com/8yYgw7y7sM2a1
-- Subscribe to the `messageReceiver` port to hear about messages coming in
-- from JS. Check out the index.html file to see how this is hooked up to a
-- WebSocket.
--
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [  receiveChunk Recv
        , receiveStop Recv
        , receiveDone Recv
        ]

