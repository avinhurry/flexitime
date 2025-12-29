require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  it "renders the edit form" do
    get edit_password_url
    expect(response).to be_successful
  end

  it "updates the password" do
    patch password_url, params: {
      password_challenge: AuthHelpers::DEFAULT_PASSWORD,
      password: "Secret6*4*2*",
      password_confirmation: "Secret6*4*2*"
    }

    expect(response).to redirect_to(root_url)
  end

  it "rejects the update with the wrong challenge" do
    patch password_url, params: {
      password_challenge: "SecretWrong1*3",
      password: "Secret6*4*2*",
      password_confirmation: "Secret6*4*2*"
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Password challenge is invalid")
  end
end
