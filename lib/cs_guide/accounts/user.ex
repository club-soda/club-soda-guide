defmodule CsGuide.Accounts.User do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "users" do
    field(:email, Fields.EmailEncrypted)
    field(:email_hash, Fields.EmailHash)
    field(:email_plaintext, Fields.EmailPlaintext, virtual: true)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
