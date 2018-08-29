# 3 Days Review

Principle of this design is discovery. Discovery in this context means “no dead ends”. Discovery does not always work from the top of the site (the homepage) down to a listing: there is a lot more lateral movement as well as lateral entry from a search engine to consider. In all of these instances there should be no dead ends.

## Updated Home Page
The home page has been updated to more closely align with the feedback from our session on Wednesday. The page follows the following order:
1. Search box and quick links to the drinks explorer
2. Promoted or Recommended Venues
3. Promotion of Venue Nomination
4. Drinks Playlist
5. Promotion of Join Club Soda website
6. Drinks Playlist
7. Footer
There is also an alternate search bar submitted which features two separate inputs for drinks and venues.

## Results Pages
My emphasis for Venues has been on Sorting over filtering, whereas in Drinks I have focused on filtering rather than sorting. This is to reflect the size of the respective datasets - filtering being more necessary for larger sets - and supports a “discovery” theme in the drinks explorer: the more filter options that cross between “types of drinks” the more lateral connections can be made e.g. “fruity” or “herbal”. Labels like these can be applied to a range of different drinks from beers to wines and cordials.
This kind of sideways exploration will be the key to pulling in users and offers a near infinite well of content ideas which can be promoted seasonally, politically - howsoever CS see fit. It also positions CS well for future development - a good “article” page is paramount in the modern web because users Google their needs and often enter websites through these side-doors. Many people might never see the home page.

## Filter/Categorisation Operation and Arrangement
the filters here are additional not exclusionary - if I search for “cherry wine beer” in the drinks explorer it recognises “wine” and “beer” as discrete values that correspond to drink-type categories. The results will therefore include both wines and beers with “Wine” and “Beer” as applied filters. This behaviour is different from, say, a filter that went looking for something that matched the terms “cherry” AND “wine” AND “beer” and would most likely return nothing.
Ideally, the system might also recognise that “cherry” is associated with various flavours of drinks (even more ideally as a “fruity” flavour) and would be able to include those drinks in the results too. However, this assumes that flavour information 1) exists 2) is accessible and consistent across drinks.
Alternatively, the system could admit to the user that it can’t recognise or process the word “cherry”.
If I were to type in the letters “Whea” the system suggests Wheat Beer as a specific category. If I click on this link or tap down to it with my keyboard, I see the drinks explorer with the “Wheat Beer” filter applied and the beer filter-tab highlighted. Clearing the “Wheat Beer” filter, either directly or through the dropdown menu, takes the user to the unfiltered Drink Explorer.

The venue results page offers a different set of filters for finding the right place. They operate in dropdown menus just like the Drinks Explorer. Results are automatically sorted by shortest distance to the searched location - wherever the maps API determines that to be. It is still to be determined how many search terms the system will be able to recognise and apply as filters, especially those which may have duel application (though if we find these we can offer a clarification dialogue).

The filtering options have been arranged horizontally across the top of the listings similar to the pattern seen on Airbnb.
This has been done for a number of reasons:
	- To emphasises the search bar as the primary tool for finding content.
	- To avoid using screen real estate with a side bar - instead the whole screen is devoted to product content. Though side bars are the go-to for filters, a side-bar was not felt to be appropriate here because its position is optimised for users to narrow down their searches as quickly as possible - we’re hoping for a little more random deviation than that.
	- To create greater proximity between filters and applied filters meaning that there should be as little confusion as possible about which filters I selected and how to turn them on and off.
	- To reflect its use: a side bar suggests one of two things - a menu OR a filter - whereas this filter is actually both.
	- To improve navigation on a mobile device because it will provide more visibility of the menu AND filters rather than being hidden under a “filter” button.

## Mixed Results
The “General” or “Ambiguous” results page features 3 different kinds of search results: Drinks, Venues, and Brands. By default All of these are shown in the order:
1. Venues near to a location that most closely matches the search term if it is very similar or identical in spelling to a place name or postcode.
2. Brands that are named in a manner that is very similar or identical in spelling to the search term and Brands that are located in the location determined in the block above.
3. Drinks that are named or have attributes very similar or identical in spelling to the search term.

Each block of content is accompanied by a call to action. In corresponding order they are:
1. See All Venues - which takes the user to the venue search results page using the same search term in the usual way. The same effect is achieved by clicking the filter for “Venues”.
2. See All Brands - Filters the content on the page to only show Brands. This has the same effect as clicking on the “Brands” filter. Optionally the search criteria could be widened to include similar brands (either in spelling or in character).
3. See All Drinks - Unless the search term is a specific Drinks Explorer filter clicking this CTA will also filter this list for drinks matching the search term in some way.
If any of these does not exist then it is not featured.
Underneath all of these results is a break and then a series of “Recommended Selections” - the playlist-style blocks (and corresponding article page) of drinks and community submissions that connect under a theme.

## A Guiding Principle
Whenever the page of content ends, but before the footer, there is a random “playlist” block to hopefully lure someone who’s scrolled this far back in. Over time, analytics on these blocks will help prioritise which to show and when, for minimising abandonment.

## Testing Next Week
A very important assumption to test is that visitors to the Club Soda Guide will know what mindful drinking is. Is it possible, for next week’s early round of testing to pull together some mindful drinkers? I wonder if this lack of awareness might affect, say, test subjects pulled from the Ministry of Startups, or indeed whether we ought to onboard them a little before beginning a test session.
