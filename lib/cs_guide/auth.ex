defmodule CsGuide.Auth do
  def validate_user(email, password) do
    with user <- CsGuide.Accounts.User.get_by(email_hash: email),
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
end
