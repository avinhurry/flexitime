require "rails_helper"

RSpec.describe Identity::PasswordResetsController, type: :request do
  let(:user) { create(:user, verified: true) }

  describe "GET /identity/password_reset/new" do
    it "should get new" do
      get new_identity_password_reset_url
      expect(response).to be_successful
    end
  end

  describe "GET /identity/password_reset/edit" do
    it "should get edit" do
      sid = user.generate_token_for(:password_reset)

      get edit_identity_password_reset_url(sid:)
      expect(response).to be_successful
    end
  end

  describe "POST /identity/password_reset" do
    context "with a valid email" do
        it "should send a password reset email" do
      expect do
        perform_enqueued_jobs do
          post identity_password_reset_url, params: { email: user.email }
        end
      end.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(response).to redirect_to(sign_in_url)
    end
  end


    context "with a non existent email" do
      it "should not send a password reset email" do
        expect do
          post identity_password_reset_url, params: { email: "invalid_email@hey.com" }
        end.not_to have_enqueued_mail

        expect(response).to redirect_to(new_identity_password_reset_url)
        expect(flash[:alert]).to eq("You can't reset your password until you verify your email")
      end
    end

    context "with an unverified email" do
      it "should not send a password reset email" do
        user.update!(verified: false)

        expect do
          post identity_password_reset_url, params: { email: user.email }
        end.not_to have_enqueued_mail

        expect(response).to redirect_to(new_identity_password_reset_url)
        expect(flash[:alert]).to eq("You can't reset your password until you verify your email")
      end
    end
  end

  describe "PATCH /identity/password_reset" do
    context "with a valid token" do
      it "should update the password" do
        sid = user.generate_token_for(:password_reset)

        patch identity_password_reset_url, params: { sid:, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }
        expect(response).to redirect_to(sign_in_url)
      end
    end

    context "with an expired token" do
      it "should not update the password" do
        sid = user.generate_token_for(:password_reset)

        travel 30.minutes do
          patch identity_password_reset_url, params: { sid:, password: "Secret6*4*2*", password_confirmation: "Secret6*4*2*" }
        end

        expect(response).to redirect_to(new_identity_password_reset_url)
        expect(flash[:alert]).to eq("That password reset link is invalid")
      end
    end
  end
end
