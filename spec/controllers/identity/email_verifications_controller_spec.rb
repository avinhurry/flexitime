require "rails_helper"

RSpec.describe Identity::EmailVerificationsController, type: :request do
  let(:user) { create(:user, verified: false) }

  before do
    sign_in_as(user)
    user.update!(verified: false)
    allow(Current).to receive(:user).and_return(user)
  end

  describe "POST /identity/email_verification" do
    it "queues an email job and redirects to root" do
      expect {
        post identity_email_verification_path(email: user.email)
      }.to change { enqueued_jobs.size }.by(1)

      expect(response).to redirect_to(root_url)
    end
  end

  describe "GET /identity/email_verification" do
    context "with a valid token" do
      it "verifies the email" do
        sid = user.generate_token_for(:email_verification)

        get identity_email_verification_url(sid: sid, email: user.email)

        expect(response).to redirect_to(root_url)
      end
    end

    context "with an expired token" do
      it "does not verify the email" do
        sid = user.generate_token_for(:email_verification)

        travel 3.days do
          get identity_email_verification_url(sid: sid, email: user.email)
        end

        expect(response).to redirect_to(edit_identity_email_url)
        expect(flash[:alert]).to eq("That email verification link is invalid")
      end
    end
  end
end
