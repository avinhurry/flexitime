require "rails_helper"

RSpec.feature "Email changes", type: :system do
  let(:user) { create(:user, email: "user@example.com") }

  scenario "updates the email address" do
    given_i_am_signed_in_as(user)
    when_i_visit_email_settings
    and_i_submit_a_new_email("new_email@hey.com")

    then_i_see_flash("Your email has been changed")
  end

  def given_i_am_signed_in_as(user)
    sign_in_as(user)
  end

  def when_i_visit_email_settings
    visit edit_identity_email_path
  end

  def and_i_submit_a_new_email(address)
    fill_in "New email", with: address
    fill_in "Password", with: AuthHelpers::DEFAULT_PASSWORD
    click_on "Save changes"
  end

  def then_i_see_flash(message)
    expect(page).to have_text(message)
  end
end
