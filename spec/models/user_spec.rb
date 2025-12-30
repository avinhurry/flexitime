require "rails_helper"

RSpec.describe User, type: :model do
  let(:password) { "verysecurepasword1234@!" }

  after do
    Current.session = nil
  end

  context "when normalizing email" do
    it "strips whitespace and downcases" do
      user = described_class.create!(email: "  TeSt@Example.com  ", password: password)

      expect(user.email).to eq("test@example.com")
    end
  end

  context "when the password changes" do
    it "removes other sessions" do
      user = described_class.create!(email: "user@example.com", password: password)
      session = user.sessions.create!
      other_session = user.sessions.create!
      Current.session = session

      user.update!(password: "SuperNewPass123!", password_confirmation: "SuperNewPass123!")

      expect(user.sessions.reload).to contain_exactly(session)
      expect(user.sessions).not_to include(other_session)
    end
  end

  context "when working days per week are out of range" do
    it "is invalid" do
      user = described_class.new(email: "user@example.com", password: password, working_days_per_week: 0)

      expect(user).not_to be_valid
      expect(user.errors[:working_days_per_week]).to be_present
    end
  end

  context "when working days per week are within range" do
    it "is valid" do
      user = described_class.new(email: "user@example.com", password: password, working_days_per_week: 4)
      user.validate

      expect(user.errors[:working_days_per_week]).to be_empty
    end
  end

  context "when contracted hours are out of range" do
    it "is invalid" do
      user = described_class.new(email: "user@example.com", password: password, contracted_hours: 0)
      user.validate

      expect(user.errors[:contracted_hours]).to be_present
    end

    it "is invalid when above the max" do
      user = described_class.new(email: "user@example.com", password: password, contracted_hours: 81)
      user.validate

      expect(user.errors[:contracted_hours]).to be_present
    end
  end

  context "when contracted hours are within range" do
    it "is valid" do
      user = described_class.new(email: "user@example.com", password: password, contracted_hours: 40)
      user.validate

      expect(user.errors[:contracted_hours]).to be_empty
    end
  end
end
