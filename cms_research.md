# CMS Research Results

## Requirement Checklist

### Wagtail

- [x] Custom types (limited)
- [x] Structure of pages and resources/types (limited)
- [x] Tagging
- [x] Good search functionality
- [ ] Access control
  - [ ] Fine grained CMS access
  - [ ] update pages from outside the CMS
- [x] Image uploads and resizing
- [ ] import data
- [x] export data (possible but not built in - requires custom code)

#### Pros:
  * Free
  * open source
  * Popular, used by big companies

#### Cons:
  * More suited for a blog type site
  * restricted to a python backend
  * lots of custom code may be required to arrange resources in the way we want
  * No way to update CMS externally/give limited access

### Contentful

- [x] Custom types
- [x] Structure of pages and resources/types
- [x] Tagging
- [x] Good search functionality
- [x] Access control
  - [ ] Fine grained CMS access
  - [x] update pages from outside the CMS
- [x] Image uploads and resizing
- [x] import data (yes, but only as json and using cli)
- [x] export data (yes, but only as json and using cli)

#### Pros
  * Popular and used by many big companies: https://www.contentful.com/#customers
  * Resource based structure is well suited to linking venues, brands and drinks
  * Back and Front end agnostic, we can use it with whatever technology we want
  * API to update content, so users/venues can add limited content without access to CMS

#### Cons
  * Paid, $39/month for the basic plan but may need to be upgraded in future if many venues sign up/many brands/drinks are added. They do mention on their site that they may offer pro bono plans for Open Source projects though: https://www.contentful.com/pricing/#payments

### Apostrophe

- [x] Custom types (limited)
- [x] Structure of pages and resources/types (limited)
- [x] Tagging
- [x] Good search functionality
- [ ] Access control
  - [ ] Fine grained CMS access
  - [ ] update pages from outside the CMS
- [x] Image uploads and resizing
- [x] import data
- [ ] export data

#### Pros
  * Free, open source
  * Used by some big companies

#### Cons
  * Not very flexible
  * WYSIWYG editor
  * No way to update CMS externally/give limited access
  * More suited for blog type sites

### Prismic

- [x] Custom types
- [x] Structure of pages and resources/types
- [x] Tagging
- [x] Good search functionality
- [ ] Access control
  - [ ] Fine grained CMS access
  - [x] update pages from outside the CMS
- [x] Image uploads and resizing
- [x] import data
- [ ] export data

Very similar to Contentful, but has a slightly less in depth API, and CMS UI is a little less intuitive. It is cheaper though, at $15/month for the basic plan.

## Recommendation

Based on my research, the CMS I would recommend is __Contentful__.

The more traditional CMSs (wagtail and apostrophe) probably wouldn't have the kind of flexibility we need, as they tend to favour a very rigid page structure, suited to a traditional blog.
While we could bend them to our will, it would likely lead to a lot of custom code that could be unwieldy and lead to more development time as the project goes on.

By contrast, a headless CMS is much less prescriptive, providing us with the data, and nothing else. This means we can create the page structure to match the designs using our own choice of technology, while the CMS handles the storage and structure of our data.

Of the headless CMSs I looked at, Contentful seems the most suited to our purposes. It separates data into resources rather than pages, meaning it would be easy to link drinks, venues and brands using many-to-many relationships, and accessing them from each other's pages.
It also has a very extensive API, both for retrieving content, and creating it (which would be useful when it comes to venues needing to add/update their own data).

It also allows for a lot of control over the data from within the CMS UI. New fields can be added to resources without needing to update the code. (In Wagtail, this would require updating the model in the python code, then performing a database migration; a very brittle process). The new fields wouldn't necessarily show on the site without a developer updating the template though, unless it was an addition that was pre-planned. (For example, we could list all categories on the search page, then when a new one is created, it would automatically show in the list).

The only disadvantage to choosing a headless CMS is that they all cost money. This is mainly because they also provide the storage of your data, meaning you don't have to pay for your own database. Contentful plans start at $39 per month for a 'micro space', which will allow us 5000 records (pages, categories, brands, drinks, venues and images are records, so assuming an image for each drink/venue/brand, we would be able to have about 2400 combined, which would hopefully be enough for the MVP phase)

(_Actually, I've just checked again and they have a free plan that provides you with one free 'micro space', meaning for the MVP we wouldn't have to pay at all if 5000 records was enough, otherwise the $39/month would provide us 10000_)
