defmodule CsGuide.Auth do
  alias CsGuide.Accounts.User

  def validate_user(email, password) do
    with %User{} = user <- User.get_by(email_hash: email),
         true <- Argon2.verify_pass(password, user.password) do
      {:ok, user}
    else
      nil ->
        with _ <- Argon2.no_user_verify() do
          {:error, "invalid credentials"}
        end

      false ->
        {:error, "invalid credentials"}
    end
  end

  def login(conn, user) do
    conn
    |> Plug.Conn.put_session(:user_id, user.entry_id)
    |> Plug.Conn.configure_session(renew: true)
  end

  def venue_owner(conn, venue) do
    current_venue_ids = conn.assigns[:venue_id] || ""
    venue_ids = current_venue_ids <> "," <> venue.entry_id
    conn
    |> Plug.Conn.put_session(:venue_id, venue_ids)
    |> Plug.Conn.configure_session(renew: true)
  end
end
