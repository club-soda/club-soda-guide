defmodule CsGuide.Email do
  use Bamboo.Phoenix, view: CsGuide.PageView

  def send_email(to, subject, message) do
    new_email()
    |> to(to)
    |> from(System.get_env("SENDERS_EMAIL"))
    |> subject(subject)
    |> text_body(message)
  end

  def send_contact_form_email(name, email, message) do
    message = """
    Message from #{email}  (#{name}):
    #{message}
    """
    new_email()
    |> to(System.get_env("CONTACT_FORM_EMAIL"))
    |> subject("New Club Soda Guide message")
    |> from(System.get_env("SENDERS_EMAIL"))
    |> text_body(message)
  end
end
