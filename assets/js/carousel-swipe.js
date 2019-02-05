var drinksCarousel = document.getElementById('drinks-carousel');
var app;
var venueCarousel = document.getElementById('venue-carousel');

if (drinksCarousel) {
  app = Elm.DrinksCarousel.init({
    node: drinksCarousel
  })
}

if (venueCarousel) {
  app = Elm.VenueCarousel.init({
    node: venueCarousel
  })
}

function swipe(el, callback){
  var swipedir;
  var startX;
  var startY;
  var distX;
  var distY;
  var threshold = 50;
  var restraint = 100;

  el.addEventListener('touchstart', function(e){
    var touchobj = e.changedTouches[0];
    swipedir = 'none';
    startX = touchobj.pageX;
    startY = touchobj.pageY;

  }, false);

  el.addEventListener('touchend', function(e){
    var touchobj = e.changedTouches[0]
    distX = touchobj.pageX - startX;
    distY = touchobj.pageY - startY;

    if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint) {
      swipedir = (distX < 0) ? 'left' : 'right';
    }

    callback(swipedir);
  }, false);
}

setTimeout(function() {
  var carousel = document.getElementById('carousel');
  if (carousel) {
    swipe(carousel, function(swipedir) {
      app.ports.swipe.send(swipedir);
    });
  }
  if (carousel) {
    swipe(carousel, function(swipedir) {
      app.ports.swipeVenue.send(swipedir);
    });
  }
});
