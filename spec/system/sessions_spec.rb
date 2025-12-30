require "rails_helper"

RSpec.feature "Sessions", type: :system do
  let(:user) { create(:user, email: "user@example.com") }

  context "when signing in" do
    scenario "signs in with valid credentials" do
      when_i_sign_in_with(user.email, AuthHelpers::DEFAULT_PASSWORD)

      then_i_see_flash("Signed in successfully")
    end
  end

  context "when already signed in" do
    scenario "shows the sessions index" do
      given_i_am_signed_in_as(user)
      when_i_visit_sessions

      then_i_see_sessions_page
    end

    scenario "signs out" do
      given_i_am_signed_in_as(user)
      when_i_sign_out

      then_i_see_flash("Signed out successfully")
    end
  end

  def given_i_am_signed_in_as(user)
    sign_in_as(user)
  end

  def when_i_sign_in_with(email, password)
    visit sign_in_url
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in"
  end

  def when_i_visit_sessions
    visit sessions_path
  end

  def when_i_sign_out
    click_on "Log out"
  end

  def then_i_see_sessions_page
    expect(page).to have_selector("h1", text: "Devices & Sessions")
  end

  def then_i_see_flash(message)
    expect(page).to have_text(message)
  end
end
