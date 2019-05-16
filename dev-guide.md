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

> More detail/insight on the history of this script, see:
[github.com/club-soda/club-soda-guide/issues/512](https://github.com/club-soda/club-soda-guide/issues/512#issuecomment-480071684)

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

_Obviously_ the _real_ environment variables
don't contain any `****` characters ... this is just a sanitised example.

Once you have _saved_ the **`.env`** file,
run the following command in your terminal:

```sh
source .env
```

## Install Dependencies

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


## Start the App

Run the application on your `localhost`:

```sh
mix phx.server
```

Visit http://localhost:4000 in your web browser. You should expect to see:

![club-soda-homepage](https://user-images.githubusercontent.com/194400/55151100-658f6380-5145-11e9-93c4-dd2c8627cb2e.png)


You will notice that the app looks quite "bare" ...
this is because it's a "content" web app
so without _content_ it will look _empty_.

You have _two_ options for getting content:
1. Get the latest data from Heroku (_real content data is good for testing UI_).
2. Run the migration scripts to insert "seed" data (_much less data_).


## Using _Real_ Data

There are many instances where having "real" data on `localhost`
is useful for UI/UX debugging.
For those cases the _easiest/fastest_ thing to do
is grab a fresh backup from Heroku
and "restore" it to your local Postgres.

These are the steps you will need to follow:

1. Visit: https://dashboard.heroku.com/apps/club-soda-guide/resources

![club-soda-guide-resources](https://user-images.githubusercontent.com/194400/55612766-e8856f00-5780-11e9-9423-b9dddace3d36.png)


Click on the "Heroku Postgres" link:
![image](https://user-images.githubusercontent.com/194400/55612833-12d72c80-5781-11e9-85f4-655f24762fba.png)

That will take you to the Datastores page:
https://data.heroku.com/datastores/a870534e-1277-4b9a-a487-0f10d551b7f3

![image](https://user-images.githubusercontent.com/194400/55612926-503bba00-5781-11e9-957a-12fb6180e98a.png)

Click on the "**Durability**" menu item:

![image](https://user-images.githubusercontent.com/194400/55612964-63e72080-5781-11e9-85c7-91b542eb5e04.png)

Scroll to the bottom of the page until you see the list of backups:

![image](https://user-images.githubusercontent.com/194400/55613010-837e4900-5781-11e9-87e5-a498f254613e.png)

Click on the "**Create Manual Backup**" button:
![image](https://user-images.githubusercontent.com/194400/55613125-cfc98900-5781-11e9-8982-325201bf46f8.png)

You will see a "***processing***" message:

![image](https://user-images.githubusercontent.com/194400/55613147-df48d200-5781-11e9-9aaf-f5588c6c33ac.png)

When the "**created**" column changes to "a minute ago":

![image](https://user-images.githubusercontent.com/194400/55613204-06070880-5782-11e9-8bf6-90caf5d24414.png)

Click the "**Download**" button:

![image](https://user-images.githubusercontent.com/194400/55613220-10c19d80-5782-11e9-94b8-d375882723f0.png)

Get the download link from your browser downloads e.g: chrome://downloads/

![image](https://user-images.githubusercontent.com/194400/55616545-f55a9080-5789-11e9-9998-bebb04059583.png)

The link is _super_ long because it contains auth token/credentials:

https://xfrtu.s3.amazonaws.com/7562f7d3-503a-4d40-a450-42dffc34f523/2019-04-05T08%3A04%3A29Z/8b390ead-83d7-4ed8-9161-97bc50263842?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAJ5HNUZMBKBNNOSYQ%2F20190405%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190405T090047Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=54ac21e88e3219f93c64efc8

> **Data Privacy/Security Note**: For you infosec conscious people out there,
in addition to changing the signature on this link so it's invalid,
all Heroku database backup download links have a 10 min expiry,
so even if the link was valid, it has _long_ since expired. 🤓

Using the command format:
`curl "http://[url]" > production.dump`
construct your curl command, e.g:

Run the command in your terminal:

```sh
curl "https://xfrtu.s3.amazonaws.com/7562f7d3-503a-4d40-a450-42dffc34f523/2019-04-05T08%3A04%3A29Z/8b390ead-83d7-4ed8-9161-97bc50263842?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAJ5HNUZMBKBNNOSYQ%2F20190405%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20190405T090047Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=54ac21e88e3219f93c64efc8" > production.dump
```

You should output similar to the following:

![image](https://user-images.githubusercontent.com/194400/55616696-49657500-578a-11e9-9b18-a27023f41e99.png)

Now run the `pg_restore` command:

```sh
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d cs_guide_dev production.dump
```
Given that the `--verbose` flag was used, you should see a bunch of output in terminal:

![image](https://user-images.githubusercontent.com/194400/55616777-7f0a5e00-578a-11e9-893d-0bc681ae97a7.png)

That's a good sign it worked ... Open the database in your chosen GUI/CLI and you should see:
Postico:
![image](https://user-images.githubusercontent.com/194400/55616832-a103e080-578a-11e9-89c2-75606c93dbd0.png)

DBeaver:
![image](https://user-images.githubusercontent.com/194400/55616875-bbd65500-578a-11e9-9777-b6e4e2bf2f23.png)


> Thanks to @wrburgess for his helpful gist:
https://gist.github.com/wrburgess/5528649 ❤️


## Importing Data

The fastest way to on-board a lot of venues into the Guide
is to import their data (_with permission_) in bulk.
This section takes you through the steps to add
a spreadsheet of data into the Guide App's Database.

### 1. Backup and Restore the Database

_Before_ importing any `new` data,
ensure that you have made a backup of the production database.
Follow the instructions in:
[dev-guide.md#using-real-data](https://github.com/club-soda/club-soda-guide/blob/master/dev-guide.md#using-real-data)
to backup, download and import the production data.

Having the latest production data on your `localhost`
is _essential_ to testing the import process.

### 2. Download the Data as CSV

In order to import the data,
we need to have it in a useable format.
Most of our imports are stored in Google Drive as spreadsheets.

Open the Google Drive file,
click "Download as >" and select "Comma-separated values":

![club-soda-data-import-download-as-csv](https://user-images.githubusercontent.com/194400/57693131-5fdfd580-7640-11e9-9429-19f0dcf71d7c.png)

### 3. Move the `.csv` file to the `./temp` directory and Re-name it.

The file you download from Google Sheets will be named something
human-friendly like `Bermondsey-Pub-Company - Sheet1.csv` in our case:

![club-soda-data-import-filename](https://user-images.githubusercontent.com/194400/57755263-5d38bb00-76e8-11e9-8b50-6bec5c553fcb.png)

Move the `.csv` file you just downloaded to the `/temp` directory
and re-name it to something machine readable
e.g: `temp/bermondsey_pub_company.csv`.
Removing spaces and using underscores in the filename
is necessary for Elixir to understand it.

![moved-and-renamed-file](https://user-images.githubusercontent.com/194400/57756173-9f62fc00-76ea-11e9-9cd7-ad5d5a681268.png)

### 4. Review the Column Headers

When you open the `.csv` file,
the first row/line are the "headers" (_or column names_).
The spreadsheet will have human-readable names e.g:

![csv-file-headers](https://user-images.githubusercontent.com/194400/57756010-3c716500-76ea-11e9-9afa-3692d7fb8d5e.png)

Copy that first line of the file and past it into your text editor.

```csv
Venue Name,Parent company,Street Address,City,Post Code,Telephone,Venue Type,
Email,Description,Website,Facebook,Twitter,Instagram,
Low/No Alcohol Drink 1,Low/No Alcohol Drink 2,Low/No Alcohol Drink 3,
Low/No Alcohol Drink 4,Low/No Alcohol Drink 5,Low/No Alcohol Drink 6,
Low/No Alcohol Drink 7,Low/No Alcohol Drink 8,Low/No Alcohol Drink 9,
Low/No Alcohol Drink 10,Low/No Alcohol Drink 11,Low/No Alcohol Drink 12,
Low/No Alcohol Drink 13,Low/No Alcohol Drink 14,Low/No Alcohol Drink 15,
Low/No Alcohol Drink 16,Low/No Alcohol Drink 17,Low/No Alcohol Drink 18
```
> **Note**: we have split the header into multiple lines
for _legibility_.
A valid CSV file headers are always on a _single_ line.

### 5. Map the CSV Column Headers to Database Fields

In order to import the data,
we need to go through the csv file column headers
and map them to the database column names.

The following is the list of **`venues`** table fields
This list is separated by spaces
because that's how our `Elixir` venue importer script `new_venues.exs`
needs them.


```csv
venue_name parent_company address city postcode phone_number venue_types
email description website facebook twitter instagram
drink_1 drink_2 drink_3 drink_4 drink_5 drink_6
drink_7 drink_8 drink_9 drink_10 drink_11 drink_12
drink_13 drink_14 drink_15 drink_16 drink_17 drink_18
```
> **Note**: this needs to be a _single_ line of code
when you paste it into the `priv/repo/new_venues.exs` below;
we have split it into 5 lines to aid _legibility_.
Also, some `.csv` files do not contain _all_ the fields
in the database (venues) table
e.g: **`num_cocktails`** is not present in the case of Berbomondsey.

### 6. Add line to `new_venues.exs`

Open the `priv/repo/new_venues.exs` file
(_our venue importer script_)
and search for the
[`@venues`](https://github.com/club-soda/club-soda-guide/blob/master/priv/repo/new_venues.exs#L6)
map.
The `@venues` map is a key-value lookup
of the chains of venues we have imported
and the corresponding field names for the `csv` files.

Add the following line to the `@venues` map:

```elixir
bermondsey_pub_company:
  ~w(venue_name parent_company address city postcode phone_number venue_types email description website facebook twitter instagram drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14 drink_15 drink_16 drink_17 drink_18)a,
```

`bermondsey_pub_company` corresponds to the csv file name
and the contents of the `~w()a` is the
[sigil](https://elixir-lang.org/getting-started/sigils.html#word-lists)
for a "word list";
in our case the list of database column headers.
the list of words should be on a single line.
(_some horizontal scrolling may be required ..._)

Save the file and `new_venues.exs` and prepare to _run_ it!

String.split("venue_name parent_company address city postcode phone_number venue_types email description website facebook twitter instagram drink_1 drink_2 drink_3 drink_4 drink_5 drink_6 drink_7 drink_8 drink_9 drink_10 drink_11 drink_12 drink_13 drink_14 drink_15 drink_16 drink_17 drink_18", " ") |> Enum.join(',')


### 7. Run the `new_venues.exs` import script


> Before attempting to run the `new_venues.exs` script,
ensure that you have a **`IMPORT_FILES_DIR`**
key-value in your **`.env`** file
and that you have the environment variable set
by running `source .env`.
If you don't yet have an `.env` file,
GOTO: [dev-guide.md#environment-variables](https://github.com/club-soda/club-soda-guide/blob/master/dev-guide.md#environment-variables)

Open your database GUI of choice
and confirm the number of rows for the `venues` table. e.g:

![7428-rows](https://user-images.githubusercontent.com/194400/57765501-80219a00-76fd-11e9-9a5d-cf7f8605b051.png)


Run the `new_venues.exs` script with the following command:
```sh
mix run priv/repo/new_venues.exs
```

After _successfully_ running the script,
refresh the DB and you should see the increase in the number of records.
e.g: 7486
![7486-rows](https://user-images.githubusercontent.com/194400/57783825-b9bacb00-7726-11e9-9c99-fb90ca1ceea1.png)

7486 - 7428 = 58.
58 corresponds to the number of rows in the `.csv` file (_minus the header row_)

#### Confirm the Venue Managers (Users) are Associated with the Venue

Open your PostgreSQL GUI and visit the `venue_users` table.

`venue_users` before running the `new_venues.exs` script: **310** rows

![venue_users_before_import](https://user-images.githubusercontent.com/194400/57850496-f5f93480-77d5-11e9-886f-9c7421f79be1.png)

`venue_users` after running the `new_venues.exs` script: **367** rows

![venue_users_after_import](https://user-images.githubusercontent.com/194400/57850768-af580a00-77d6-11e9-83ce-cdb64fe6b55f.png)

This is consistent with the data we just imported
because there are 58 rows but one of the rows
does _not_ have an email address
so we only expect 57 new entries
in the `venue_users` table:

![bermondsey-pub-without-email-address](https://user-images.githubusercontent.com/194400/57850885-01009480-77d7-11e9-9081-da6f7a91b133.png)

Visit: http://localhost:4000/admin/users

Newly imported venue admin users viewable in Admin UI:

![club-soda-users-bermondsey](https://user-images.githubusercontent.com/194400/57852281-a8cb9180-77da-11e9-9193-baee5d4f5c69.png)


### 8. _Test_ Importing Venues on Staging Environment

Visit: https://club-soda-guide-staging.herokuapp.com/admin/users

BEFORE:

![staging-users](https://user-images.githubusercontent.com/194400/57860532-eafdce80-77ec-11e9-832d-a3231d6bb56e.png)

#### Tasks to run the script and insert data into staging:

+ [x] get DATABASE_URL environment variable from staging:
https://dashboard.heroku.com/apps/club-soda-guide-staging/settings

+ [x] add DATABASE_URL to `.env` file on `localhost`

+ [x] MIX_ENV=prod mix run priv/repo/new_venues.exs


AFTER:
![staging-users-bermondsey](https://user-images.githubusercontent.com/194400/57860877-87c06c00-77ed-11e9-9aa3-2c225d44fe51.png)


### 9. _Test_ Importing Venues on PRODUCTION Environment

+ [x] get `DATABASE_URL` environment variable from prod:
https://dashboard.heroku.com/apps/club-soda-guide/settings
+ [x] add `DATABASE_URL` to `.env` file on `localhost`

+ [x] repeat for `ENCRYPTION_KEYS` environment variable for prod

+ [x] MIX_ENV=prod mix run priv/repo/new_venues.exs




### _Superseded_

> The following docs are superseded
and only kept here for reference.

The existing data is imported through our [seeds file](priv/repo/seeds.exs).

The environment variable `IMPORT_FILES_DIR`
should be the path to the directory containing the csv files
(For example, if those files are hosted on AWS S3,
  it would be the path of the S3 bucket).

> On Heroku these files are stored in the **`/temp`** directory.
So we do the same on `localhost`, store them in **`club-soda-guide/temp`**.


The files should be named correctly
such that the format of the file
matches the function that will be calling it.
(That is, the brands file should be `brands.csv`,
  drinks `drinks.csv`
  and the venues `venues_1.csv`,
  `venues_2.csv`
  or `venues_3.csv`,
  depending on which format it is.
These should be named correctly already,
and as this import is only intended to be done once,
shouldn't need to be changed.
This documentation is just here as a guide
if this import function ever needs to be extended.)

If you do need to import more venues, use this script as a guide,
but you will most likely have to create a new one
based on the format of the csv file.

After new venues have been imported, you may have to run
`mix run priv/repo/update_cs_score.exs`
if any drinks were attached to venues as part of the upload process.



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

## Adding latitude and longitude values to the database

Latitude and longitude values are being used to calculate the distance from a
user to a venue. To add these values to your venues in the database run the
command...

```
mix run priv/repo/add_lat_long_to_venue.exs
```

## Deployment

The `master` branch is automatically deployed to staging.
When it's time to deploy to production follow these steps:

### Adding environment variables

If you have added any environment variables to the project since it was last
deployed that are needed for the it to work you will need to add them to heroku
as well. To do this click the `Settings` tab on the heroku dashboard.

Once here, click the `Reveal Config Vars`...

![reveal-config-vars](https://user-images.githubusercontent.com/194400/55563188-5e3ffb00-56ed-11e9-8202-2e831eee536a.png)

and enter the `key`, `value` pairs into the input boxes provided...
![env-key-value](https://user-images.githubusercontent.com/15571853/55892119-a0fe4900-5bad-11e9-81ce-57bcbb343937.png)

After entering the info, click `Add` to add the variable to heroku.

### Backup the current database

From the heroku dashboard, go to the `Resources` tab,
then click `Heroku Postgres`.

<img width="707" alt="heroku resources tab" src="https://user-images.githubusercontent.com/8939909/53745911-f69d5280-3e97-11e9-8356-c6544362ea26.png">


This will take you to the database dashboard. From here, got to the `Durability` tab, then click `Create Manual Backup`.

<img width="1259" alt="heroku postgres dashboard" src="https://user-images.githubusercontent.com/8939909/53745909-f69d5280-3e97-11e9-9e36-c1c2e6e713bf.png">

### Deploy `master` branch

Back on the Heroku dashboard, go to the `Deploy` tab.

<img width="720" alt="heroku deploy tab" src="https://user-images.githubusercontent.com/8939909/53745910-f69d5280-3e97-11e9-9cf2-65671201055e.png">

Scroll down to the bottom section: `Manual Deploy`. Make sure the branch is set to `master`, then click `Deploy Branch`.

<img width="1137" alt="heroku manual deploy" src="https://user-images.githubusercontent.com/8939909/53745912-f69d5280-3e97-11e9-90d2-40397d152d54.png">

A few minutes later, you should be notified that the deployment is complete.
