# Dev Guide

The purpose of this guide is to walk you through running the App
both on `localhost` and deployment to `staging` (_test environment_)
and `production`.
Our aim is to _pre-empt_ any _obvious_ questions as much as possible,
but if we have skipped a step or you are scratching your head
wondering how to do/run something, please open an issue
and we will gladly/promptly answer and improve this guide:
https://github.com/club-soda/club-soda-guide/issues


## Setup on `localhost`

In order to get the project setup and running on your `localhost`
you will need to have the following installed:

+ [x] **`Elixir`** and **`Phoenix`** see:
[github.com/dwyl/**learn-phoenix-framework**](https://github.com/dwyl/learn-phoenix-framework#installation)
+ [x] **`PostgreSQL`** see:
[github.com/dwyl/**learn-postgresql**](https://github.com/dwyl/learn-postgresql)
+ [x] **`Node.js`** and **`Elm`** see:
[github.com/dwyl/**learn-elm**#how](https://github.com/dwyl/learn-elm#how)

### Run the Following Commands

Clone the `git` repository:
```sh
git clone git@github.com:club-soda/club-soda-guide.git && cd club-soda-guide
```

Install the **`Elixir`** dependencies:
```sh
mix deps.get
```

Create the database:
```sh
mix ecto.create
```

Create the database _schema_ (_tables_):
```sh
mix ecto.migrate
```

## Environment Variables

In order to run the application on your `localhost` you will need to have a
a few environment variables defined.

Rather than listing them here in the docs,
we use **Heroku** as our "single source of truth" for Environment Variables.

> Note: if you are **`new`** to (_or "rusty" on_) Environment Variables
please see:
[github.com/dwyl/**learn-environment-variables**](https://github.com/dwyl/learn-environment-variables)
> And/or if you need a primer on Heroku,
please see:
[github.com/dwyl/**learn-heroku**](https://github.com/dwyl/learn-heroku)

To get the latest environment variables you will need access to
the **`club-soda-guide-staging`** Heroku app.

First visit the "Settings" tab for your Heroku App:
https://dashboard.heroku.com/apps/club-soda-guide-staging/settings

Click on the "**Reveal Config Vars**" button:

![reveal-config-vars](https://user-images.githubusercontent.com/194400/55563188-5e3ffb00-56ed-11e9-8202-2e831eee536a.png)


Then Run this script in your web browser's developer console:

```js
var keys = document.getElementsByClassName('config-var-key');
var vals = document.getElementsByClassName('config-var-value');
var vars = '';
for (var i = 0; i < keys.length - 1; i++) {
  var key = keys[i].value
  if (key && key !== 'DATABASE_URL' && key !== 'HEROKU_POSTGRESQL') {
    var index = (i == 0) ? 0 : i * 2; // cause there are two values for every key ... 🙄
    vars = vars + 'export ' + keys[i].value + '=' + vals[index].value + '\n';
  }
}
console.log(vars);
```

> More detail/insight on the history of this script,
see: https://github.com/dwyl/learn-heroku/issues/35

You should see something like this:

![export-heroku-config-vars-script-output](https://user-images.githubusercontent.com/194400/55563638-369d6280-56ee-11e9-8e84-c3131e8b0a8a.png)

Copy the output from the browser console and paste it into your **`.env`** file.

```sh
export AWS_ACCESS_KEY_ID=AKIA****************
export AWS_S3_BUCKET=bucket-name
export AWS_S3_REGION=eu-west-1
export AWS_SECRET_ACCESS_KEY=****************
export DATABASE_URL=postgres://databasename@compute.amazonaws.com:5432/password
export ENCRYPTION_KEYS='****************='
export GOOGLE_MAPS_API_KEY=****************
export HEROKU_POSTGRESQL=postgres://databasename@compute.amazonaws.com:5432/password
export IMPORT_FILES_DIR=temp
export SECRET_KEY_BASE=****************
export SENDERS_EMAIL=hello@example.com
export SES_PORT=25
export SES_SERVER=email-smtp.eu-west-1.amazonaws.com
export SITE_URL=https://www.example.com
export SMTP_PASSWORD=****************
export SMTP_USERNAME=AKIA****************
export URL=your-app.herokuapp.com
```


## Using _Real_ Data


## Importing Data

The existing data is imported through our [seeds file](priv/repo/seeds.exs).

The environment variable `IMPORT_FILES_DIR` should be the path to the directory containing the csv files (For example, if those files are hosted on AWS S3, it would be the path of the S3 bucket).

The files should be named correctly such that the format of the file matches the function that will be calling it. (That is, the brands file should be `brands.csv`, drinks `drinks.csv` and the venues `venues_1.csv`, `venues_2.csv` or `venues_3.csv`, depending on which format it is. These should be named correctly already, and as this import is only intended to be done once, shouldn't need to be changed. This documentation is just here as a guide if this import function ever needs to be extended.)

If you do need to import more venues, use this script as a guide, but you will most likely have to create a new one based on the format of the csv file.

After new venues have been imported, you may have to run `mix run priv/repo/update_cs_score.exs` if any drinks were attached to venues as part of the upload process.



## Creating Admin Users

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
