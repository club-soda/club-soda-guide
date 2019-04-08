## Dev Guide

### Importing Data

The existing data is imported through our [seeds file](priv/repo/seeds.exs).

The environment variable `IMPORT_FILES_DIR` should be the path to the directory containing the csv files (For example, if those files are hosted on AWS S3, it would be the path of the S3 bucket).

The files should be named correctly such that the format of the file matches the function that will be calling it. (That is, the brands file should be `brands.csv`, drinks `drinks.csv` and the venues `venues_1.csv`, `venues_2.csv` or `venues_3.csv`, depending on which format it is. These should be named correctly already, and as this import is only intended to be done once, shouldn't need to be changed. This documentation is just here as a guide if this import function ever needs to be extended.)

If you do need to import more venues, use this script as a guide, but you will most likely have to create a new one based on the format of the csv file.

After new venues have been imported, you may have to run `mix run priv/repo/update_cs_score.exs` if any drinks were attached to venues as part of the upload process.

### Creating Admin Users

To create an admin user, open iex with `iex -S mix`.

From here do:

```
iex> %CsGuide.Accounts.User{} |> CsGuide.Accounts.User.changeset(%{email: "", password: "", verified: NaiveDateTime.utc_now(), role: "site_admin"}) |> CsGuide.Accounts.User.insert()
```
remember to define the email address and password, e.g:
```elixir
%CsGuide.Accounts.User{} |> CsGuide.Accounts.User.changeset(%{email: "nelson@dwyl.io", password: "BeExcellentToEachOther", verified: NaiveDateTime.utc_now(), role: "site_admin"}) |> CsGuide.Accounts.User.insert()
```

Filling in the empty strings as necessary.

### Adding latitude and longitude values to the database

Latitude and longitude values are being used to calculate the distance from a
user to a venue. To add these values to your venues in the database run the
command...

```
mix run priv/repo/add_lat_long_to_venue.exs
```

### Deployment

The `master` branch is automatically deployed to staging.
When it's time to deploy to production follow these steps:

#### Backup the current database

From the heroku dashboard, go to the `Resources` tab,
then click `Heroku Postgres`.

<img width="707" alt="heroku resources tab" src="https://user-images.githubusercontent.com/8939909/53745911-f69d5280-3e97-11e9-8356-c6544362ea26.png">


This will take you to the database dashboard. From here, got to the `Durability` tab, then click `Create Manual Backup`.

<img width="1259" alt="heroku postgres dashboard" src="https://user-images.githubusercontent.com/8939909/53745909-f69d5280-3e97-11e9-9e36-c1c2e6e713bf.png">

#### Deploy `master` branch

Back on the Heroku dashboard, go to the `Deploy` tab.

<img width="720" alt="heroku deploy tab" src="https://user-images.githubusercontent.com/8939909/53745910-f69d5280-3e97-11e9-9cf2-65671201055e.png">

Scroll down to the bottom section: `Manual Deploy`. Make sure the branch is set to `master`, then click `Deploy Branch`.

<img width="1137" alt="heroku manual deploy" src="https://user-images.githubusercontent.com/8939909/53745912-f69d5280-3e97-11e9-90d2-40397d152d54.png">

A few minutes later, you should be notified that the deployment is complete.
