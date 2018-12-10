defmodule CsGuide.Accounts.User do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "users" do
    field(:email, Fields.EmailEncrypted)
    field(:email_hash, Fields.EmailHash)
    field(:email_plaintext, Fields.EmailPlaintext, virtual: true)
    field(:password, Fields.Password)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:admin, :boolean, default: false)

    many_to_many(
      :venues,
      CsGuide.Resources.Venue,
      join_through: "venues_users",
      join_keys: [user_id: :id, venue_id: :id],
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email, :password, :admin])
    |> validate_required([:email])
    |> put_email_hash()
  end

  def put_email_hash(user) do
    case get_change(user, :email) do
      nil -> user
      email -> put_change(user, :email_hash, email)
    end
  end
end
