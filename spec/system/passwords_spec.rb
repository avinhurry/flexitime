require "rails_helper"

RSpec.feature "Passwords", type: :system do
  let(:user) { create(:user, email: "user@example.com") }

  context "when changing the password" do
    scenario "updates the password" do
      given_i_am_signed_in_as(user)
      when_i_visit_the_change_password_page
      and_i_submit_a_new_password("Secret6*4*2*")

      then_i_see_flash("Your password has been changed")
    end
  end

  def given_i_am_signed_in_as(user)
    sign_in_as(user)
  end

  def when_i_visit_the_change_password_page
    visit edit_password_path
  end

  def and_i_submit_a_new_password(password)
    fill_in "Password challenge", with: AuthHelpers::DEFAULT_PASSWORD
    fill_in "New password", with: password
    fill_in "Confirm new password", with: password
    click_on "Save changes"
  end

  def then_i_see_flash(message)
    expect(page).to have_text(message)
  end
end
