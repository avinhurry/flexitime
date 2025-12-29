module SystemHelpers
  DEFAULT_PASSWORD = "verysecurepasword1234@!"

  def sign_in_as(user, password: DEFAULT_PASSWORD)
    visit sign_in_url
    fill_in "Email", with: user.email
    fill_in "Password", with: password
    click_on "Sign in"

    expect(page).to have_current_path(root_url)
    user
  end
end
