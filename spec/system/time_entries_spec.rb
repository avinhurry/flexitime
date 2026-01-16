require "rails_helper"

RSpec.feature "Time entries", type: :system do
  let(:user) { create(:user, email: "user@example.com") }

  scenario "records a time entry with a break" do
    travel_to Time.zone.local(2025, 3, 7, 9, 0) do
      given_i_am_signed_in_as(user)
      when_i_record_a_time_entry
      then_i_see_the_entry_listed
    end
  end

  # TODO: Re-enable once system tests move to Playwright.
  xscenario "starts and ends a break from the edit page", :js do
    travel_to Time.zone.local(2025, 3, 7, 9, 0) do
      given_i_am_signed_in_as(user)
      when_i_open_the_edit_page_for_an_entry
      and_i_start_a_break
      then_i_see_the_break_is_in_progress
      when_i_end_the_break
      then_i_see_the_break_is_stopped
    end
  end

  def when_i_open_the_edit_page_for_an_entry
    entry = user.time_entries.create!(
      clock_in: Time.zone.local(2025, 3, 7, 9, 0),
      clock_out: Time.zone.local(2025, 3, 7, 17, 0)
    )

    visit edit_time_entry_path(entry)
  end

  def and_i_start_a_break
    click_on "Start break timer"
  end

  def then_i_see_the_break_is_in_progress
    expect(page).to have_text("In progress")
  end

  def when_i_end_the_break
    click_on "In progress"
  end

  def then_i_see_the_break_is_stopped
    expect(page).to have_text("Start break timer")
  end

  def given_i_am_signed_in_as(user)
    sign_in_as(user)
  end

  def when_i_record_a_time_entry
    click_on "New Time Entry", match: :first

    fill_in "Clock in", with: "2025-03-07T09:00"
    fill_in "Clock out", with: "2025-03-07T17:00"
    fill_in "Break start", with: "12:00"
    fill_in "Break end", with: "12:30"

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
