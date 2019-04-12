defmodule CsGuide.Accounts.VenueUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "venues_users" do
    belongs_to :user, CsGuide.Accounts.User
    belongs_to :venue, CsGuide.Resources.Venue
  end

  @doc false
  def changeset(venue_user, attrs \\ %{}) do
    venue_user
    |> cast(attrs, [:user_id, :venue_id])
  end
end