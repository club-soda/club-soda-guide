module Helpers exposing (changeSpacesToDashes)


changeSpacesToDashes : String -> String
changeSpacesToDashes str =
    str |> String.split " " |> String.join "-"
