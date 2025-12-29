require "rails_helper"

RSpec.feature "Password resets", type: :system do
  let(:user) { create(:user, email: "user@example.com", verified: true) }

  context "when requesting a reset" do
    scenario "sends reset instructions" do
      given_i_am_on_the_sign_in_page
      when_i_request_a_password_reset

      then_i_see_flash("Check your email for reset instructions")
    end
  end

  context "when using a reset token" do
    scenario "updates the password" do
      given_i_have_a_valid_reset_link
      when_i_submit_a_new_password("Secret6*4*2*")

      then_i_see_flash("Your password was reset successfully. Please sign in")
    end
  end

  def given_i_am_on_the_sign_in_page
    visit sign_in_url
  end

  def when_i_request_a_password_reset
    click_on "Forgot your password?"
    fill_in "Email", with: user.email
    click_on "Send password reset email"
  end

  def given_i_have_a_valid_reset_link
    sid = user.generate_token_for(:password_reset)
    visit edit_identity_password_reset_url(sid: sid)
  end

  def when_i_submit_a_new_password(password)
    fill_in "New password", with: password
    fill_in "Confirm new password", with: password
    click_on "Save changes"
  end

  def then_i_see_flash(message)
    expect(page).to have_text(message)
  end
end
