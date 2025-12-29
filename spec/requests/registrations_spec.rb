require "rails_helper"

RSpec.describe "Registrations", type: :request do
  it "renders the sign up form" do
    get sign_up_url
    expect(response).to be_successful
  end

  context "when the submission is valid" do
    it "signs up" do
      expect do
        post sign_up_url, params: {
          email: "lazaronixon@hey.com",
          password: "Secret1*3*5*",
          password_confirmation: "Secret1*3*5*",
          contracted_hours: 37,
          working_days_per_week: 5
        }
      end.to change(User, :count).by(1)

      created_user = User.order(:id).last
      expect(created_user.working_days_per_week).to eq(5)
      expect(response).to redirect_to(root_url)
    end
  end

  context "when the submission is invalid" do
    it "renders errors" do
      expect do
        post sign_up_url, params: {
          email: "lazaronixon@hey.com",
          password: "short",
          password_confirmation: "short",
          contracted_hours: 37,
          working_days_per_week: 5
        }
      end.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Password is too short")
    end
  end
end
