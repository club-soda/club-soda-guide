var search = document.getElementById('search');
if (search) {
  var types = {
    "Tonics and Mixers": "Tonics & Mixers",
    "Spirits and Premixed": "Spirits & Premixed"
  };

  var drink_type = types[dtype] || dtype;
  Elm.SearchDrink.init({
    node: search, flags: Object.assign({}, { dtype_filter: drink_type, drinks: drinks, term: searchTerm, types_styles: typesAndStyles  })
  })
}

var searchVenue = document.getElementById('search-venue');
if (searchVenue) {
  Elm.SearchVenue.init({
    node: searchVenue, flags: { venues: venues, term: searchTerm }
  })
}

var searchAll = document.getElementById('search-all');
if (searchAll) {
  Elm.SearchAll.init({
    node: searchAll, flags: { drinks: drinks, venues: venues, term: searchTerm }
  })
}
