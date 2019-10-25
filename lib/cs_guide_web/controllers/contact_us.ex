defmodule CsGuideWeb.ContactUsController do
  use CsGuideWeb, :controller
  alias CsGuide.ContactUs

  @mailer Application.get_env(:cs_guide, :mailer) || CsGuide.Mailer

  def new(conn, _params) do
    changeset = ContactUs.changeset(%ContactUs{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  @doc """
  Send message in email
  """
  def create(conn, %{"contact_us" => message }) do
    changeset = ContactUs.changeset(%ContactUs{}, message)
    # send email if form validation valid
    if changeset.valid? do
      IO.inspect(changeset.changes)
     # CsGuide.Email.send_contact_form_email(changeset.changes.name, changeset.changes.email, changeset.changes.message)
     # |> @mailer.deliver_now()

      # reset changeset for empty form
      changeset = ContactUs.changeset(%ContactUs{}, %{})
      render(conn, "new.html", changeset: changeset,  message_sent: true)
    # error in the form, send back changeset
    else
      # to display the error on the form Phoenix check the action property
      # as we do not use Repo for the contact form we need to craete the action manually
      {_, changeset} = Ecto.Changeset.apply_action(changeset, :insert)
      IO.inspect(changeset)
      render(conn, "new.html", changeset: changeset)
    end
  end
end
