defmodule CsGuideWeb.DrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink

  def index(conn, _params) do
    # drinks = Drinks.all()
    # render(conn, "index.html", drinks: drinks)
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
        |> redirect(to: drink_path(conn, :show, drink))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    drink = Drink.get(id)
    render(conn, "show.html", drink: drink)
  end

  def edit(conn, %{"id" => id}) do
    # drink = Resources.get_drink!(id)
    # changeset = Resources.change_drink(drink)
    # render(conn, "edit.html", drink: drink, changeset: changeset)
  end

  def update(conn, %{"id" => id, "drink" => drink_params}) do
    # drink = Resources.get_drink!(id)

    # case Resources.update_drink(drink, drink_params) do
    #   {:ok, drink} ->
    #     conn
    #     |> put_flash(:info, "Drink updated successfully.")
    #     |> redirect(to: drink_path(conn, :show, drink))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "edit.html", drink: drink, changeset: changeset)
    # end
  end

  def delete(conn, %{"id" => id}) do
    # drink = Resources.get_drink!(id)
    # {:ok, _drink} = Resources.delete_drink(drink)

    # conn
    # |> put_flash(:info, "Drink deleted successfully.")
    # |> redirect(to: drink_path(conn, :index))
  end
end
