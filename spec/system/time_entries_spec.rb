require "rails_helper"

RSpec.feature "Time entries", type: :system do
  let(:user) { create(:user, email: "user@example.com") }

  scenario "records a time entry with a lunch break" do
    travel_to Time.zone.local(2025, 3, 7, 9, 0) do
      given_i_am_signed_in_as(user)
      when_i_record_a_time_entry
      then_i_see_the_entry_listed
    end
  end

  def given_i_am_signed_in_as(user)
    sign_in_as(user)
  end

  def when_i_record_a_time_entry
    click_on "New Time Entry", match: :first

    fill_in "Clock in", with: "2025-03-07T09:00"
    fill_in "Clock out", with: "2025-03-07T17:00"
    fill_in "Lunch in (optional)", with: "12:00"
    fill_in "Lunch out (optional)", with: "12:30"

    click_on "Save entry"
  end

  def then_i_see_the_entry_listed
    within "table" do
      expect(page).to have_text("7 Mar 2025, 09:00")
      expect(page).to have_text("7 Mar 2025, 17:00")
      expect(page).to have_text("0h 30m")
      expect(page).to have_text("7h 30m")
    end
  end
end
