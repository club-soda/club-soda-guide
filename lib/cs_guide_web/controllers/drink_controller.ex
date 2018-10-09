defmodule CsGuideWeb.DrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, _params) do
    drinks = Drink.all()
    render(conn, "index.html", drinks: drinks)
  end

  def new(conn, _params) do
    changeset = Drink.changeset(%Drink{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"drink" => drink_params}) do
    case Drink.insert(drink_params) do
      {:ok, drink} ->
        conn
        |> put_flash(:info, "Drink created successfully.")
        |> redirect(to: drink_path(conn, :show, drink.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    drink = Drink.get(id)
    render(conn, "show.html", drink: drink)
  end

  def edit(conn, %{"id" => id}) do
    drink = Drink.get(id)
    changeset = Drink.changeset(drink)
    render(conn, "edit.html", drink: drink, changeset: changeset)
  end

  def update(conn, %{"id" => id, "drink" => drink_params}) do
    drink = Drink.get(id)

    case Drink.update(drink, drink_params) do
      {:ok, drink} ->
        conn
        |> put_flash(:info, "Drink updated successfully.")
        |> redirect(to: drink_path(conn, :show, drink.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", drink: drink, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    drink = Drink.get(id)
    {:ok, _drink} = Drink.delete(drink)

    conn
    |> put_flash(:info, "Drink deleted successfully.")
    |> redirect(to: drink_path(conn, :index))
  end
end
