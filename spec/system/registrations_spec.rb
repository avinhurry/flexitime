require "rails_helper"

RSpec.feature "Registrations", type: :system do
  scenario "redirects sign up to sign in with a message" do
    visit sign_up_url

    expect(page).to have_current_path(sign_in_path)
    expect(page).to have_text("Sign-ups are closed. This app is invite-only - contact me if you need access.")
  end
end
