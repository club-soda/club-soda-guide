defmodule CsGuideWeb.SponsorController do
  use CsGuideWeb, :controller
  alias CsGuide.Sponsor

  def index(conn, _params) do
    sponsors = Sponsor.all()

    render(conn, "index.html", sponsors: sponsors)
  end

  def new(conn, _params) do
    changeset = Sponsor.changeset(%Sponsor{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def replaceExistingShowingSponsor() do
    showing_sponsor = Sponsor.getShowingSponsor()

    params = %{name: showing_sponsor.name, body: showing_sponsor.body, show: false}

    showing_sponsor
    |> Sponsor.changeset(params)
    |> Sponsor.update()
  end

  def create(conn, %{"sponsor" => sponsor_params}) do
    if sponsor_params["show"] == "true" && Sponsor.getShowingSponsor() do
      replaceExistingShowingSponsor()
    end

    case Sponsor.insert(sponsor_params) do
      {:ok, _sponsor} ->
        conn
        |> put_flash(:info, "Sponsor created successfully.")
        |> redirect(to: sponsor_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    sponsor = Sponsor.get(id)
    changeset = Sponsor.changeset(sponsor)
    render(conn, "edit.html", sponsor: sponsor, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sponsor" => sponsor_params}) do
    sponsor = Sponsor.get(id)
    changeset = Sponsor.changeset(sponsor, sponsor_params)

    if sponsor_params["show"] == "true" do
      replaceExistingShowingSponsor()
    end

    case Sponsor.update(changeset) do
      {:ok, _sponsor} ->
        conn
        |> put_flash(:info, "Sponsor updated successfully.")
        |> redirect(to: sponsor_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sponsor: sponsor, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sponsor = Sponsor.get(id)
    {:ok, _sponsor} = Sponsor.delete(sponsor)

    conn
    |> put_flash(:info, "Sponsor deleted successfully.")
    |> redirect(to: sponsor_path(conn, :index))
  end
end
