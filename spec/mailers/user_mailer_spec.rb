require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user, email: "user@example.com") }

  describe "#password_reset" do
    it "sends the reset email" do
      mail = described_class.with(user: user).password_reset

      expect(mail.subject).to eq("Reset your password")
      expect(mail.to).to eq([ user.email ])
    end
  end

  describe "#email_verification" do
    it "sends the verification email" do
      mail = described_class.with(user: user).email_verification

      expect(mail.subject).to eq("Verify your email")
      expect(mail.to).to eq([ user.email ])
    end
  end
end
