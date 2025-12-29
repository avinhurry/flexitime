require "rails_helper"

RSpec.describe Session, type: :model do
  after do
    Current.user_agent = nil
    Current.ip_address = nil
  end

  context "when creating a session" do
    it "captures the request metadata from Current" do
      user = create(:user)
      Current.user_agent = "RSpec"
      Current.ip_address = "127.0.0.1"

      session = user.sessions.create!

      expect(session.user_agent).to eq("RSpec")
      expect(session.ip_address).to eq("127.0.0.1")
    end
  end
end
