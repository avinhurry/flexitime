require "rails_helper"

RSpec.describe Identity::EmailsController, type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
  end

  describe "GET /identity/email/edit" do
    it "returns a success response" do
      get edit_identity_email_path
      expect(response).to be_successful
    end
  end

  describe "PATCH /identity/email" do
    context "with valid password challenge" do
      it "updates the email and redirects to root" do
        patch identity_email_path, params: { email: "new_email@hey.com", password_challenge: "verysecurepasword1234@!" }
        expect(response).to redirect_to(root_url)
        user.reload
        expect(user.email).to eq("new_email@hey.com")
      end
    end

    context "when the email is unchanged" do
      it "does not enqueue a verification email" do
        expect {
          patch identity_email_path, params: { email: user.email, password_challenge: "verysecurepasword1234@!" }
        }.not_to have_enqueued_mail(UserMailer, :email_verification)

        expect(response).to redirect_to(root_url)
      end
    end

    context "with invalid password challenge" do
      it "does not update the email and renders unprocessable entity" do
        patch identity_email_path, params: { email: "new_email@hey.com", password_challenge: "SecretWrong1*3" }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Password challenge is invalid")
        user.reload
        expect(user.email).to eq("lazaro@example.com")
      end
    end
  end
end
