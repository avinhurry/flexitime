require "rails_helper"

RSpec.feature "Navigation", type: :system do
  scenario "shows admin-only create user link" do
    admin = create(:user, admin: true)

    sign_in_as(admin)

    expect(page).to have_link("Account", href: account_path)
    expect(page).to have_link("Create user", href: sign_up_path)
  end

  scenario "hides create user link for non-admins" do
    user = create(:user)

    sign_in_as(user)

    expect(page).to have_link("Account", href: account_path)
    expect(page).not_to have_link("Create user", href: sign_up_path)
  end
end
