defmodule CsGuide.AddEmailsToExistingVenues do
  @moduledoc """
  This modules is building off of the work done in new_venues.exs and signup.ex.
  It will be used to create venue admin users and associate them with existing
  venues.
  """

  alias CsGuide.{Repo, ScriptHelpers}
  alias CsGuide.Accounts.{User, VenueUser}
  alias CsGuide.Resources.Venue

  @venues ScriptHelpers.venues()

  def add_emails(filepath, filename) do
    csv = File.read!(filepath) # read csv file
    venue_keys = @venues[filename] # get the keys for the specific csv file

    csv
    |> ScriptHelpers.csv_to_list_of_maps(venue_keys) #
    |> Enum.reduce([], fn v, acc ->
      [_address, postcode] = ScriptHelpers.get_address_and_postcode(v)

      case Venue.get_by(venue_name: v.venue_name, postcode: postcode) do
        nil ->
          # if the venue doens't exist return {:error, venue_name doesn't exist}
          err = {:error, "#{v.venue_name} doesn't exist"}
          [err | acc]

          # if the venue does exist
        venue ->
          # check the email is valid and try selecting user by the email address
          case Fields.Validate.email(String.trim(v.email)) && User.get_by(email_hash: v.email) do
            # if email is invalid
            false ->
              err = {:error, "Email #{v.email} is invalid"}
              [err | acc]

            # if email is valid but user does not exist
            nil ->
              params = %{email: v.email, role: "venue_admin"}
              changeset = User.changeset(%User{}, params)

              # if not, create the user and add association to venue
              {:ok, user} = User.insert(changeset)
              # associate the user with the venue (add them to venues_users table)
              Repo.insert!(%VenueUser{venue_id: venue.id, user_id: user.id})
              acc

            # if user does exist
            user ->
              # check if they are assoiciated with the venue.
              case Repo.get_by(VenueUser, venue_id: venue.id, user_id: user.id) do
                # if not, add association
                [] ->
                  Repo.insert!(%VenueUser{venue_id: venue.id, user_id: user.id})
                  acc

                # if so, do nothing
                _venue_user ->
                  acc
              end
          end
      end
    end)
    |> IO.inspect(label: "===> ")
  end
end

directory = System.get_env("IMPORT_FILES_DIR")

remove_extension = fn(filename) ->
  filename
  |> String.slice(0..-5)
  |> String.to_atom()
end

directory
|> File.ls!()
|> Enum.each(fn file ->
  if file =~ ".csv" do
    filepath = directory <> "/" <> file
    filename = remove_extension.(file)
    CsGuide.AddEmailsToExistingVenues.add_emails(filepath, filename)
  end
end)
