var search = document.getElementById('search');
if (search) {
  var types = {
    "Tonics and Mixers": "Tonics & Mixers",
    "Spirits and Premixed": "Spirits & Premixed"
  };

  var drink_type = types[dtype] || dtype;
  var elmApp = Elm.SearchDrink.init({
    node: search, flags: Object.assign({}, { dtype_filter: drink_type, drinks: drinks, term: searchTerm, types_styles: typesAndStyles })
  })

  closeDropdown(elmApp)
}

var searchVenue = document.getElementById('search-venue');
if (searchVenue) {
  Elm.SearchVenue.init({
    node: searchVenue, flags: {
      venues: venues,
      term: searchTerm,
      venueTypes: venueTypes,
      postcode: postcode,
      locationSearch: locationSearch
    }
  })
}

var searchAll = document.getElementById('search-all');
if (searchAll) {
  Elm.SearchAll.init({
    node: searchAll, flags: { drinks: drinks, venues: venues, term: searchTerm }
  })
}

function closeDropdown(elmApp) {
  //ids defined in SearchDrink.elm
  var excludeIds = ["pill-type-style", "dropdown-types-styles"];

  document.addEventListener('click', function (e) {
    var ids = getParentsId(e.target);
    var close = excludeIds.filter(function (id) {
      return ids.indexOf(id) >= 0;
    }).length == 0;

    elmApp.ports.closeDropdownTypeStyle.send(close)
  })
}

function getParentsId(elt) {
  var res = [];
  while (elt) {
    res.push(elt.id);
    elt = elt.parentNode;
  }
  return res.filter(Boolean);
}

window.addEventListener("scroll", function (e) {
  // Detect whether user has scrolled to the bottom of the page
  // Then send message to the Elm app
  var top = (document.documentElement && document.documentElement.scrollTop) || document.body.scrollTop;
  var height = (document.documentElement && document.documentElement.scrollHeight) || document.body.scrollHeight;

  // We send the message if they have scrolled to within 10% 
  // of the bottom of the page to create a smoother transition
  if (top + window.innerHeight >= height - (height / 10)) {
    elmApp.ports.scroll.send(true);
  }
})