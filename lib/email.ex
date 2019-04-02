defmodule CsGuide.Email do
  use Bamboo.Phoenix, view: CsGuide.PageView

  def send_email(to, subject, message) do
    new_email()
    |> to(to)
    |> from(System.get_env("SENDERS_EMAIL"))
    |> subject(subject)
    |> text_body(message)
  end
end