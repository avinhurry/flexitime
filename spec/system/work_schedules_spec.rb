require "rails_helper"

RSpec.feature "Work schedules", type: :system do
  let(:user) { create(:user, email: "user@example.com") }

  scenario "updates the work schedule" do
    given_i_am_signed_in_as(user)
    when_i_update_the_work_schedule

    then_i_see_the_updated_schedule
  end

  def given_i_am_signed_in_as(user)
    sign_in_as(user)
  end

  def when_i_update_the_work_schedule
    visit edit_work_schedule_path
    fill_in "Contracted hours", with: "32"
    fill_in "Working days per week", with: "4"
    click_on "Save changes"
  end

  def then_i_see_the_updated_schedule
    expect(page).to have_text("Work schedule updated")
    expect(page).to have_text("32")
    expect(page).to have_text("4")
  end
end
