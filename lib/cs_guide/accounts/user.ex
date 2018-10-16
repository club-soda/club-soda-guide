defmodule CsGuide.Accounts.User do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:entry_id, :string)
    field(:deleted, :boolean)

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
