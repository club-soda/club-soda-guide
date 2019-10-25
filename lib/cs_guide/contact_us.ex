defmodule CsGuide.ContactUs do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contact_us" do
    field(:name, :string)
    field(:email, :string)
    field(:message, :string)
    field(:gdpr, :boolean)
    timestamps()
  end

  def changeset(contact_us, attrs \\ %{}) do
    email_regex = ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

    contact_us
    |> cast(attrs, [:email, :name, :message])
    |> validate_required([:email, :message])
    |> validate_acceptance(:gdpr)
    |> validate_format(:email, email_regex)
  end
end
