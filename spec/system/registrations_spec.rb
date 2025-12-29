require "rails_helper"

RSpec.feature "Registrations", type: :system do
  context "when signing up" do
    scenario "creates an account" do
      given_i_am_on_the_sign_up_page
      when_i_submit_registration

      then_i_see_flash("Welcome! You have signed up successfully")
    end
  end

  def given_i_am_on_the_sign_up_page
    visit sign_up_url
  end

  def when_i_submit_registration
    fill_in "Email", with: "lazaronixon@hey.com"
    fill_in "Password", with: "Secret6*4*2*"
    fill_in "Password confirmation", with: "Secret6*4*2*"
    fill_in "Contracted hours", with: "37"
    fill_in "Working days per week", with: "5"
    click_button "Sign up"
  end

  def then_i_see_flash(message)
    expect(page).to have_text(message)
  end
end
