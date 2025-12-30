require "rails_helper"

RSpec.feature "Account", type: :system do
  let(:user) do
    create(:user, email: "user@example.com", contracted_hours: 35, working_days_per_week: 4)
  end

  scenario "shows the account summary" do
    given_i_am_signed_in_as(user)
    when_i_visit_the_account_page

    then_i_see_the_account_summary
  end

  def given_i_am_signed_in_as(user)
    sign_in_as(user)
  end

  def when_i_visit_the_account_page
    visit account_path
  end

  def then_i_see_the_account_summary
    expect(page).to have_text("Account")
    expect(page).to have_text("Signed in as #{user.email}")
    expect(page).to have_text("Contracted hours")
    expect(page).to have_text("35")
    expect(page).to have_text("Working days per week")
    expect(page).to have_text("4")
    expect(page).to have_link("Edit work schedule", href: edit_work_schedule_path)
  end
end
