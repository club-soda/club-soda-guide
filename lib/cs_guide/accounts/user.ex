defmodule CsGuide.Accounts.User do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "users" do
    field(:email, Fields.EmailEncrypted)
    field(:email_hash, Fields.EmailHash)
    field(:email_plaintext, Fields.EmailPlaintext, virtual: true)
    field(:password, Fields.Password)
    field(:password_confirmation, Fields.Password, virtual: true)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:admin, :boolean, default: false)
    field(:role, CsGuide.RoleEnum)
    field(:verified, :naive_datetime)
    field(:password_reset_token, :string)
    field(:password_reset_token_expiry, :naive_datetime)

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
    |> cast(attrs, [
      :email, :password, :admin, :role, :verified, :password_reset_token,
      :password_reset_token_expiry
    ])
    |> validate_required([:email])
    |> put_email_hash()
    |> unique_constraint(:email_hash)
  end

  def set_password_changeset(user, attrs) do
    user
    |> cast(attrs, ~w(password password_confirmation)a)
    |> validate_required(~w(password password_confirmation)a)
    |> validate_confirmation(:password)
  end

  def put_email_hash(user) do
    case get_change(user, :email) do
      nil -> user
      email -> put_change(user, :email_hash, email)
    end
  end

  def reset_password_token(user, duration) do
    token = 48 |> :crypto.strong_rand_bytes |> Base.url_encode64
    expiry_time =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(duration)

    params = %{password_reset_token: token, password_reset_token_expiry: expiry_time}

    user
    |> cast(params, [:password_reset_token, :password_reset_token_expiry])
    |> CsGuide.Repo.update!()
  end

  def verify_user(user) do
    user
    |> cast(%{verified: NaiveDateTime.utc_now()}, [:verified])
    |> CsGuide.Repo.update!()
  end
end
