defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.Repo
  alias CsGuide.Accounts
  alias CsGuide.Accounts.User
  alias CsGuide.Venue

  def create(conn, %{"user" => params}) do
    %{"email" => email} = params

    venue =
      %{"phone_number" => phone_number, "postcode" => postcode, "venue_name" => venue_name} =
      params

    case Accounts.create_user(%{email: email}) do
      {:ok, user} ->
        case Resources.create_venue(venue) do
          {:ok, venue} ->
            conn
            |> put_flash(:info, "User created successfully.")
            |> put_view(CsGuideWeb.PageView)
            |> render(:index)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(CsGuideWeb.UserView)
        |> render(:new, changeset: changeset)
    end
  end
end
