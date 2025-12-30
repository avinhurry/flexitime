require "rails_helper"

RSpec.describe "Registrations", type: :request do
  let(:invite_only_message) do
    "Sign-ups are closed. This app is invite-only - contact me if you need access."
  end

  it "redirects the sign up form to sign in" do
    get sign_up_url
    expect(response).to redirect_to(sign_in_url)
    expect(flash[:alert]).to eq(invite_only_message)
  end

  it "blocks sign up submissions" do
    expect do
      post sign_up_url, params: {
        email: "lazaronixon@hey.com",
        password: "Secret1*3*5*",
        password_confirmation: "Secret1*3*5*",
        contracted_hours: 37,
        working_days_per_week: 5
      }
    end.not_to change(User, :count)

    expect(response).to redirect_to(sign_in_url)
    expect(flash[:alert]).to eq(invite_only_message)
  end

  context "when signed in as a non-admin" do
    let(:user) { create(:user, password: AuthHelpers::DEFAULT_PASSWORD) }

    before do
      sign_in_as(user)
    end

    it "redirects the sign up form to sign in" do
      get sign_up_url
      expect(response).to redirect_to(sign_in_url)
      expect(flash[:alert]).to eq(invite_only_message)
    end
  end

  context "when signed in as an admin" do
    let(:admin) { create(:user, admin: true, password: AuthHelpers::DEFAULT_PASSWORD) }

    before do
      sign_in_as(admin)
    end

    it "renders the sign up form" do
      get sign_up_url
      expect(response).to be_successful
    end

    it "allows admin to create a user" do
      expect do
        post sign_up_url, params: {
          email: "new.user@example.com",
          contracted_hours: 37,
          working_days_per_week: 5
        }
      end.to change(User, :count).by(1)

      expect(response).to be_successful
      expect(response.body).to include("Temporary password")
      expect(response.body).to include("new.user@example.com")
    end
  end
end
