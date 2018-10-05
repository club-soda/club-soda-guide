defmodule CsGuide.Accounts.User do
  use Ecto.Schema
  use CsGuide.AppendOnly
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:entry_id, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> insert_entry_id()
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
