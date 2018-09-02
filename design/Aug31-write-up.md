# Friday 31st Aug Write up

## Venues
Updates include a couple of routes into this page - clicking the Venues link in the navbar and searching for a venue with the home page search bar.

Arriving on the venues page without a search term and the site will ask for access to your device’s location. Accept, and the venues you see will be ordered by proximity to your presumed location. Refuse, and you’ll see venues listed by Club Soda score until a search term is entered.

The map view is toggled off by default but can be toggled on. Following discussion with Clare in the previous week, this is something to be tested: whether users want to see the map or not. A simple enough A/B test would be able to gather data on the number of users toggling in either direction which should give us an idea of general preferences.

All Venue Filters work on change of state. So, when the user toggles a filter the search results update.

The Venue wireframe demonstrates the “card flip” feature which reveal more information about a product.

There is an important assumption in these wireframes that the brands that venues will list the individual products they serve, not just the brands. The decision to operate on this assumption was based on the that:
1. some venues will upload all of the brands they stock regardless of the alcohol content of the drinks of those brands. e.g. saying you stock Heineken when you do not actually stock Heineken Blue.
2. Visitors to a venues site can see what is actually available at the venue.

## Brands

~Member Brands vs Non-member Brands~

As a user advocate my position is as follows - the experience ought not be diminished by business objectives. And so, there are some key areas where differences are struck between the two types of brands and some areas where there is no discernible difference.

Non-member brands ability to customise there brand page is limited. They cannot upload a hero image, only enter the name of their brand. They also cannot add key social media links. Additionally, they are not offered larger promotional UI spots for their products as demonstrated on the longer Big Drop wireframe.

2 key balances must be struck:

**Reward and Punishment**: Make the non-members features too limited and the value and integrity of the entire site will be put in to question. Offer no tangible benefit to membership (in terms of brand metrics i.e. click through, sales etc) and free accounts may abound.

**UX and Treatment Bias**: The fact that a brand is a member of the club soda guide or not is of little concern to our main user group. What they will be concerned about is if it seems that there is an arbitrary change in treatment of a subject. These cause confusion and reduce trustworthiness. For example, if it becomes harder to compare two products because one of them is missing features and there’s no way to understand why or change that, then the balance is probably off.

Perhaps non-member brands do not appear in “Similar/Recommended products” or “Drink Playlists/Selections” sections since this is Club Soda curated content and more legitimately biassed towards its own business objectives.

## Drinks
The unfiltered/unsearched Drinks Explorer must follow certain parameters:
- Member brands top the list followed by non-member brands.
- Some popular examples of each category of drink are visible across the first 16 entries (for the browsing user).
- Should the determine it valuable this would also be a good place to advertise “playlists/selections” unless and until the list is filtered or searched.

All Drink Filters work on change of state. So, when the user toggles a filter the search results update
