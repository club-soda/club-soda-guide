module TypeAndStyle exposing
    ( Filter
    , FilterId
    , FilterType(..)
    , SubFilters(..)
    , TypesAndStyles
    , getDrinkTypesAndStyles
    , getFilterById
    , getFilterId
    , getFilterName
    , getFilterType
    )


type alias TypesAndStyles =
    { typeName : String, styles : List { styleName : String } }


type alias Filter =
    ( FilterType, String, SubFilters )


type SubFilters
    = SubFilters (List Filter)


type alias FilterId =
    String


type FilterType
    = Type
    | Style


getDrinkTypesAndStyles : List TypesAndStyles -> List Filter
getDrinkTypesAndStyles typesAndStyles =
    List.map
        (\{ typeName, styles } ->
            ( Type
            , typeName
            , SubFilters
                (List.map (\{ styleName } -> ( Style, styleName, SubFilters [] )) styles
                    |> List.sortBy (\( _, name, _ ) -> name)
                )
            )
        )
        typesAndStyles
        |> List.sortBy (\( _, name, _ ) -> name)


getFilterName : Filter -> String
getFilterName ( _, filter, _ ) =
    filter


getFilterId : Filter -> FilterId
getFilterId ( typeFilter, filter, _ ) =
    case typeFilter of
        Type ->
            "type-" ++ filter

        Style ->
            "style-" ++ filter


getFilterById : FilterId -> List Filter -> Maybe Filter
getFilterById filterId filters =
    let
        filter =
            List.head filters

        rest =
            List.tail filters
    in
    case filter of
        Nothing ->
            Nothing

        Just flt ->
            let
                ( typeFilter, id, SubFilters subFilters ) =
                    flt
            in
            if getFilterId flt == filterId then
                filter

            else
                case getFilterById filterId subFilters of
                    Just f ->
                        Just f

                    Nothing ->
                        case rest of
                            Nothing ->
                                Nothing

                            Just r ->
                                getFilterById filterId r


getFilterType : Filter -> FilterType
getFilterType ( typeFilter, _, _ ) =
    typeFilter
