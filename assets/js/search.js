var search = document.getElementById('search');
if (search) {
  var types = {
    "Tonics and Mixers": "Tonics & Mixers",
    "Spirits and Premixed": "Spirits & Premixed"
  };

  var params = window.location.search;
  var qs = getQueryParams(params)
  var drink_type = (qs.drink_type && qs.drink_type.replace(/_/g, " ")) || "none";
  drink_type = types[drink_type] || drink_type;
  var term = qs.term || "";
  Elm.SearchDrink.init({
    node: search, flags: Object.assign({}, { dtype_filter: drink_type, drinks: drinks, term: term  })
  })
}

var searchVenue = document.getElementById('search-venue');
if (searchVenue) {
  var params = window.location.search;
  var qs = getQueryParams(params)
  var term = qs.term || "";
  Elm.SearchVenue.init({
    node: searchVenue, flags: { venues: venues, term: term }
  })
}

var searchAll = document.getElementById('search-all');
if (searchAll) {
  Elm.SearchAll.init({
    node: searchAll, flags: { drinks: drinks, venues: venues, term: searchTerm }
  })
}

function getQueryParams(query) {
  var res = {}
  query = query.slice(1).split('&');
  query.map(function (part) {
    var key;
    var value;
    part = part.split('=');
    key = part[0];
    value = part[1];
    if (!res[key]) {
      res[key] = value;
    } else {
      if (!Array.isArray(res[key])) {
        res[key] = [res[key]];
      }

      res[key].push(value);
    }
  });
  return res;
}
