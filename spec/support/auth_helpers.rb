module AuthHelpers
  def sign_in_as(user)
    post sign_in_path, params: { email: user.email, password: "verysecurepasword1234@!" }
    user.reload
  end
end
