module AuthHelpers
  DEFAULT_PASSWORD = "verysecurepasword1234@!"

  def sign_in_as(user, password: DEFAULT_PASSWORD)
    post sign_in_path, params: { email: user.email, password: password }
    user.reload
  end
end
