# Club Soda Guide
Mindful Drinking Movement - Club Soda MVP 2.0

### [Design Documents](/design)

## Why?

The Club Soda Guide has been created to help **make a world where nobody has to
feel out of place if they're not drinking**.

## Who?

The guide is for anyone who wishes not to drink, whether that's a little or all
of the time. We call this mindful drinking. This group of people we have broadly
called consumers, however there are many subsets of consumers that we will delve
into in more detail in the future.

To help provide mindful drinkers with information on low / non alcoholic drinks
and places where they can enjoy them we are also focussing on drink brand
representatives and venue managers. Not forgetting, the team at CS HQ who will
run and maintain the site.

Here are the user personas for these groups:

![Persona, Nisha the Consumer](https://user-images.githubusercontent.com/16775804/46004041-d5933300-c0a9-11e8-9c97-c7ea0ad38d9e.png "Persona, Nisha the Consumer")

![Persona, Bradley the Brand Manager](https://user-images.githubusercontent.com/16775804/46004238-49354000-c0aa-11e8-801b-858d137f6b1b.png "Persona, Bradley the Brand Manager")

![Persona, Vicky the Venue Manager](https://user-images.githubusercontent.com/16775804/46004426-cb256900-c0aa-11e8-8faa-31878125a4d4.png "Persona, Vicky the Venue Manager")

![Persona, Jussi from Club Soda](https://user-images.githubusercontent.com/16775804/46004730-7c2c0380-c0ab-11e8-96b1-267bdc416001.png "Persona, Jussi from Club Soda")

## What?

The site acts as a place of discovery for consumers to find low / non alcoholic
drinks and venues that serve them. It will also provide brands and venues with
the opportunity to connect and understand their consumers better. We hope this
will drive a community that owns the mindful drinking movement.

## Live Site

The site is live at https://www.clubsodaguide.com

The staging site, for testing of new features is at https://club-soda-guide-staging.herokuapp.com

# User Guide

In the following guide, all URLs should be appended to whichever site you are
using from above, either the live or staging site.   
This means that when you see `/search/drinks` in the user guide for example,
you can use either
https://www.clubsodaguide.com/search/drinks or https://club-soda-guide-staging.herokuapp.com/search/drinks .

### Listing a Venue

In the current iteration of the app, venue managers can sign up and add their venue.

To sign up, visit `/users/new`, or click on the 'List a Venue' button on the top left of any page.

<img src="https://user-images.githubusercontent.com/8939909/46817864-c681d580-cd77-11e8-8a50-ff87fa446391.png" alt="'List a Venue' Button" width="200"/>

From there, you will see a sign up form, enabling venue managers to sign up with an
email address and add their venue and its details (email address, post code and
  venue type are mandatory fields).

### Editing a Venue

After you sign up, you'll be taken to the venue's listing page where you can add more details to your venue.

<img width="500" alt="Sample Venue Page" src="https://user-images.githubusercontent.com/4185328/58019686-05da8680-7afe-11e9-938e-2e9d8dd76aa8.png">

Clicking `add description` will take you to the edit view of the venue where you
can add new details or edit existing ones.  
If you wish to add paragraph breaks to the description of a venue use `<br>` to
create line breaks. One `<br>` starts a new line, two `<br>` creates one line gap:

![description text area](https://user-images.githubusercontent.com/16775804/51027842-ca491200-1589-11e9-8044-50764c6b0afb.png)
![a venue description with line breaks](https://user-images.githubusercontent.com/16775804/51027818-be5d5000-1589-11e9-8e42-0b001163d16e.png)

:warning: When adding a website to your venue, it must begin with `http://` or
`https://` to be valid. :warning:

### Adding Drinks to Your Venue

_If you own the venue listing_, you can also **add/edit the drinks** a venue stocks.
You can do this by scrolling to the bottom of the venue page and choosing the
'Add/Remove Drinks Stocked' card. You can then select the drinks you stock which are
listed under each brand.

![adding-drinks-to-a-venue](https://user-images.githubusercontent.com/4185328/58051802-12d19700-7b4b-11e9-9937-6cf773b6e844.png)

If you serve _alcohol free cocktails_ you can also let  visitors to the site
know how many kinds you serve by adding a number to the box at the bottom of the
stocklist form. Hint: these count towards you Club Soda Score!

![alcohol-free-cocktails-box](https://user-images.githubusercontent.com/4185328/58052152-026dec00-7b4c-11e9-9279-c89261a23fe1.png)


### Searching

#### Venues

Venues can be searched for by venue name, location or _post code_ (see below).

The search is run **case insensitive** on the **name** and **address** of the venues.
The venues matching the search term are displayed first by _Club Soda Score_ (highest first)
and then sorted alphabetically alphabetically.

Example of a search on venues with "London"
![search venues](https://user-images.githubusercontent.com/6057298/49628521-6d7f9800-f9dc-11e8-9a38-5d62f4873d5e.png)

#### Searching by post code
Searching for a **partial post code** works in the same way as the standard search
and will display any venues and drinks found with this combination of letters and numbers
in the name or address
![searching-for-partial-post-code](https://user-images.githubusercontent.com/6057298/52043498-c597ce00-2537-11e9-8344-19eaa54dc9b7.png)

Searching for a **full post code** calculates the latitude and longitude of that
post code and returns search results for venues _near_ this post code, within a
30km radius.
![searching-for-full-post-code](https://user-images.githubusercontent.com/4185328/52587805-c8959700-2e32-11e9-8a8c-ede156ecd679.png)

#### Drinks
Example of a search on drinks with "beer"
![image](https://user-images.githubusercontent.com/6057298/49628671-77ee6180-f9dd-11e8-8946-300c0c5e91e4.png)

The search is run **case insensitive** on the **name** and on the **description** of the drinks.

When a drop-down is selected, a pill is displayed above the drop-down
which allows the user to see which filters have been applied at a glance and
also to quickly unselect them

![drink-type-filter-pills](https://user-images.githubusercontent.com/4185328/52588512-8c633600-2e34-11e9-8b80-1c50048b2bd1.png)

# Admin Guide

The Club Soda team has the ability to add, edit and delete various details to do with
drinks, brands, venues, retalers/wholesalers and users on the site.
The team also has access to create and edit static pages as well as update the
'Sponsors' block on the homepage.

**These are password protected and can be accessed by admins only.**
Club Soda (CS) team admins _can create new admin users_ so please speak to a member
of the CS team if you need an admin account.

These are the elements of the site that can be amended in this way and their
corresponding URLs:
- Users `/admin/users`
- Brands `/admin/brands`
- Drinks `/admin/drinks`
  - Drink types `/admin/drink_types`
  - Drink style `/admin/drink_styles`
- Venues `/admin/venues`
  - Venue type `/admin/venue_types`
- Retailers `/admin/retailers`
  - Discount Codes `/admin/discount_codes`
- Wholesalers `/admin/wholesalers`
- Static Pages `/admin/static_pages`
- Sponsors `/admin/sponsor`

All of these links are also available by visiting `/admin`.

## Creating, Editing & Deleting Instances

The ***brand, drinks and venues*** pages by and large have the same basic mechanics:
+ You will be shown a list of all instances of that item that exist (brands, drinks or venues)
+ Click `Show` to visit the instance's page
  + Note: If you are logged in as an admin or a venue manager, you will see more
  than standard site visitors as you have the power to edit certain portions of the page
+ Click `Edit` to edit its details; or
+ Click `Delete` to delete the instance

Here is an example of the 'All venues' page where you can pick any of the options
discussed above (though the full venue list here is only one venue):

![image](https://user-images.githubusercontent.com/16775804/47349854-67dc2600-d6ac-11e8-8cd8-ff634e743fd3.png)

### Websites and social media handles
All websites for venues, retailers or brands must begin with `http://` or
`https://` to be valid.

## Venues and Drinks

### Venue Types

A ***venue type*** such a 'Pub' or 'Cafe' is a mandatory field when a venue manager
is creating a new venue. You can see a list of all venue types at `/admin/venue_types`
where you can show, edit and delete them as with the venues.

CS Admins can edit the venue types at `/admin/venue_types/new`.

<img width="250" alt="New Venue Type" src="https://user-images.githubusercontent.com/4185328/58056678-e6714700-7b59-11e9-8e76-bf248de4b760.png">

:warning: It is important to note that some of the venue _existing_ types are relied upon
in parts of the code.
Changing the _existing_ types as of the time of delivery of the site may break
elements of the site as they no longer match.
This is the case for the `retailer` and `wholesaler` types. **If you wish to change
these two types then it's best to consult with the development team first.**

When you add/edit a type its fields will be updated in the main category
to which it belongs. E.g. If you add a new venue type it will become a new option
under venue types in the new venue form. So you could add 'family friendly' as a
new type and then when you create a new venue you would now have the ability to
select 'family friendly' as the venue type.

### Drink Types and Styles

Drink ***types*** operate in much the same way as [venue types](#Venue-Types) and
can be found at `/admin/drink_types`. They can be created, edited and deleted in
the same way as well.

![drink-types](https://user-images.githubusercontent.com/4185328/58056981-18cf7400-7b5b-11e9-9f35-6091922262a2.png)

A drink ***styles*** are essentially _sub-categories_ of drink types, such as
'Sparkling', 'Botanical' or 'Kombucha'. When you create or edit a drink style, you
also determine which drink type it belongs to.

A drink style can be linked to multiple drink types:

![edit-drink-style](https://user-images.githubusercontent.com/6057298/50739630-25ba7f00-11db-11e9-94ca-7f2cd995979d.png)

The relations between types and styles will then be automatically displayed in the
filter dropdown on the drinks search page that users see:

![search-drinks-dropdown](https://user-images.githubusercontent.com/4185328/58057204-fe49ca80-7b5b-11e9-87fd-ec21abfde37c.png)

### Uploading Drink and Venue Images

To upload a drink image, go to `admin/drinks`, then select `show` on the drink you want to upload an image for.

<img width="500" alt="drinks list" src="https://user-images.githubusercontent.com/8939909/48944120-6442f580-ef1d-11e8-9173-31b01d4bf126.png">

There you will see an `Upload Image` button. Click this and it will take you to the upload image page.

<img width="250" alt="drink page" src="https://user-images.githubusercontent.com/8939909/48944137-73c23e80-ef1d-11e8-839c-621c1d07353e.png">

Select the image you want to upload and click submit. Drinks images should ideally
be 6:9 or 600px x 900px. Images can be uploaded in jpg or png format.

<img width="250" alt="upload image page" src="https://user-images.githubusercontent.com/8939909/48944177-95bbc100-ef1d-11e8-8173-f36ba2e4a6ed.png">

If successful, you'll be taken back to the drink page and your image will display.

<img width="250" alt="drink page with image" src="https://user-images.githubusercontent.com/8939909/48944158-83418780-ef1d-11e8-9480-118293245c86.png">

To upload an image for a brand or a venue, follow the same steps, but using the `admin/brands` and `admin/venues` urls respectively.

Also, for Brands, you can select the `Use as cover photo` box when uploading an image.

<img width="250" alt="screen shot 2018-11-26 at 15 12 37" src="https://user-images.githubusercontent.com/8939909/49022795-a3777d80-f18d-11e8-8fa2-fdbf93a50048.png">

This will use this as the 'banner' image at the top of the brand page.

<img width="300" alt="screen shot 2018-11-26 at 15 15 42" src="https://user-images.githubusercontent.com/8939909/49023095-4f20cd80-f18e-11e8-8315-2e4e8fd26d31.png">

If you don't select it, the image will be set as the standard image further down the page.

<img width="300" alt="screen shot 2018-11-26 at 15 26 26" src="https://user-images.githubusercontent.com/8939909/49023590-70ce8480-f18f-11e8-8a99-74542d0ead2c.png">

Venue images and brand images should be close to a 12:4 ratio or 1280 x 426px for
best quality, but other sizes will be stretched or cropped to fit.


## Brands

The brand page contains brand information and lists all the drinks belonging to
a brand. It also includes the venues, wholesalers and retailers that stock or
sell those drinks. There are two templates for brand pages, one for members and
the other for non members. Membership status is a checkbox on the brand form.
Members have the ability to add two brand images (a cover image and one in the
body of text). Member pages also display social media links.

To add a stockist, simply add a drink from this brand to the venue as you normally would.


## Retailers
Retailers can be added in two ways:

Major supermarkets, amazon, DryDrinker and WiseBartender can be added as
retailers of a brand when the brand is created by checking the checkboxes for
those retailers on the 'New brand' form. Once you have ticked one of these boxes,
a link with the name of the retailer will then appear under the 'where to buy'
title and clicking that link will take you to the appropriate site with a search
made for the brand of that drink on that site.

To add a retailer not included in the 'New brand' form list go to
`/admin/retailers/new`. There you can fill in the details of your new retailer.
Ensure that for the website you include the `http://` or `https://` at the
beginning of the website url, otherwise the link will not work properly when
clicked on. Then from `/admin/retailers` you can click the link to add drinks to
a retailer. Once you have selected the appropriate drinks, the retailer will be
listed in the 'where to buy' section. Note: DryDrinker and WiseBartender do appear
in the `admin/retailers` list and should not be deleted. However, they do not have
a 'Add drinks' button because the way you determine which brand pages they display
on is via the 'Sold on WiseBartender' checkboxes on the new/edit brand pages.

### Retailer Discount Codes

Admins have the ability to add a
discount code that displays underneath links for DryDrinker and WiseBartender
using the options available at `/admin/discount_codes`. Each discount code can
only apply to one retailer so if you wanted to give DryDrinker and WiseBartender
the same code you would need to create the code twice (once for DD and once for
WB).

## Wholesalers

To add a wholesaler fill in the details at `/admin/wholesalers/new`. Then follow
the same procedure as for retailers to add drinks that the wholesaler stocks using
the links at `admin/wholesalers`.



## Exporting to CSV

In the main admin dashboard (`/admin`) the "download" links allow CS Admins
to download the current data to a CSV file:

![image](https://user-images.githubusercontent.com/4185328/58057459-da3ab900-7b5c-11e9-8c48-98bd9bd46f3c.png)


## Landing Page Sponsor Block

On the landing page there is a section before the footer where an admin can add
a sponsor. To do this they go to `admin/sponsor` and select 'New Sponsor'. The
name field is just for the admin's reference and doesn't display anywhere on the
site in the public view so it doesn't matter what name you give. The body is
where the admin puts in html that they wish to display above the footer. The
html is flexible to be whatever you wish so you can style it or put in an image
for example. An image must be hosted however so you don't upload it in the admin
area, you just put in the url like this:

```
<div class="db tc">
  <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZd4vv6b9hAcNuzR2rurs5aiKQtVVy6iAp4WrF30LrVrQrI615DA" class="w-50 w-20-ns" />
</div>
```

This is how it would look (above and below the CS image are the other parts of
the landing page and footer):

![example of sponsor image](https://user-images.githubusercontent.com/16775804/52727792-e3d8e180-2fad-11e9-8651-e6b4f619d074.png)

Only one sponsor will be displayed on the landing page at a time, the sponsor
which displays is that the one that has the 'Display on the landing page' box
ticked. When you tick this box on one sponsor it will reset all other sponsors
so they no longer display on the landing page.

### Static Pages

When you create a static page, you have the ability to write HTML or markdown in
the body field:

```
<h1> h1 text </h1>
<h2> h2 text </h2>
<h3> h3 text </h3>
<p> p text </p>
<strong> strong text </strong>
<i> italic text </i>

<ul>
  <li>Coffee</li>
  <li>Tea</li>
  <li>Milk</li>
</ul>

<ol>
  <li>Coffee</li>
  <li>Tea</li>
  <li>Milk</li>
</ol>

# h1 markdown
## h2 markdown
### h3 markdown
```

This is what you will see on the page:
![rendered html from body example](https://user-images.githubusercontent.com/15571853/55817371-510b7d80-5aec-11e9-9bc2-f2c4b5dc1b53.png)

As you can see, some of these elements already have default styling for sizing.
However if you wish to style an element in an alternative way to what you see here
you can use [inline styling](https://www.w3schools.com/css/css_howto.asp).


<hr />

# Developer?

GOTO: [dev-guide.md](https://github.com/club-soda/club-soda-guide/blob/master/dev-guide.md)
