require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  it "renders the sign in form" do
    get sign_in_url
    expect(response).to be_successful
  end

  it "signs in" do
    post sign_in_url, params: { email: user.email, password: AuthHelpers::DEFAULT_PASSWORD }
    expect(response).to redirect_to(root_url)

    follow_redirect!
    expect(response).to be_successful
  end

  it "rejects invalid credentials" do
    post sign_in_url, params: { email: user.email, password: "SecretWrong1*3" }
    expect(response).to redirect_to(sign_in_url(email_hint: user.email))
    expect(flash[:alert]).to eq("That email or password is incorrect")

    get root_url
    expect(response).to redirect_to(sign_in_url)
  end

  it "renders the sessions index" do
    sign_in_as(user)
    get sessions_url
    expect(response).to be_successful
  end

  it "signs out" do
    sign_in_as(user)

    delete session_url(user.sessions.last)
    expect(response).to redirect_to(sessions_url)

    follow_redirect!
    expect(response).to redirect_to(sign_in_url)
  end
end
