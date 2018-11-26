defmodule CsGuideWeb.DrinkController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.Drink
  alias CsGuide.Images.DrinkImage

  import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, _params) do
    drinks =
      Drink.all()
      |> Drink.preload(:brand)
      |> Enum.sort_by(& &1.name)

    render(conn, "index.html", drinks: drinks)
  end

  def json_index(conn, _params) do
    drinks =
      Drink.all()
      |> Drink.preload([:brand, :drink_types, :drink_images])

    json(
      conn,
      Enum.sort_by(drinks, fn d -> Map.get(d, :weighting, 0) end, &>=/2)
      |> Enum.map(fn d ->
        %{
          name: d.name,
          brand: d.brand.name,
          abv: d.abv,
          drink_types: Enum.map(d.drink_types, fn t -> t.name end),
          description: d.description,
          image:
            case List.last(d.drink_images) do
              nil ->
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyT_ehuzfLvJKLPOAVjobqWtZjFO1--mgpQb_NJmq0wIfpEc5SyXkuPxpG"

              img ->
                "https://s3-eu-west-1.amazonaws.com/club-soda-images/#{img.entry_id}"
            end
        }
      end)
    )
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
        |> redirect(to: drink_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    drink =
      Drink.get(id)
      |> Drink.preload([:brand, :venues, :drink_images])

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
        |> redirect(to: drink_path(conn, :index))

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

  def add_photo(conn, %{"id" => id}) do
    render(conn, "add_photo.html", id: id)
  end

  def upload_photo(conn, params) do
    CsGuide.Repo.transaction(fn ->
      with {:ok, drink_image} <- DrinkImage.insert(%{drink: params["id"]}),
           {:ok, _} <- CsGuide.Resources.upload_photo(params, drink_image.entry_id) do
        {:ok, drink_image}
      else
        val ->
          Repo.rollback(val)
      end
    end)
    |> case do
      {:ok, _} -> redirect(conn, to: drink_path(conn, :show, params["id"]))
      {:error, _} -> render(conn, "add_photo.html", id: params["id"], error: true)
    end
  end
end
