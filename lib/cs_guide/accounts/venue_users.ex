defmodule CsGuide.Accounts.VenueUser do
  use Ecto.Schema

  @primary_key false
  schema "venues_users" do
    belongs_to :user, CsGuide.Accounts.User
    belongs_to :venue, CsGuide.Resources.Venue
  end
end