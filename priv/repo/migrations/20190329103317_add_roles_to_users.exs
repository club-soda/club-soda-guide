defmodule CsGuide.Repo.Migrations.AddRolesToUsers do
  use Ecto.Migration
  alias CsGuide.Accounts.User

  def up do
    # adds a role column to the user table
    alter table(:users) do
      add(:role, :string)
      add(:verified, :naive_datetime)
      add(:password_reset_token, :string)
      add(:password_reset_token_sent_at, :naive_datetime)
    end

    # ensures that role column is added to the users table before attempting the
    # next steps
    flush()

    # Updates all users to add a role to them. If a user has the admin column
    # set to true, then their role is a site_admin. If the role was false then
    # they are a venue_admin
    User.all()
    |> Enum.map(fn(user) ->
      params =
        case user.admin do
          true ->
            %{role: "site_admin", verified: user.inserted_at}

          _ ->
            %{role: "venue_admin"}
        end

      user
      |> Ecto.Changeset.cast(params, [:role, :verified])
      # |> User.update()
      # Having to use Repo update to update the current users in the database
      # as the User.update function was causing the existing users to no longer
      # be able to log in
      # Have opened an issue relating to this here...
      # https://github.com/dwyl/alog/issues/56
      |> CsGuide.Repo.update()
    end)
  end

  def down do
    alter table(:users) do
      remove(:role)
      remove(:verified)
      remove(:password_reset_token)
      remove(:password_reset_token_sent_at)
    end
  end
end
