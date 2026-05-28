require "rails_helper"

RSpec.describe DayCredit, type: :model do
  describe ".default_credited_minutes_for" do
    it "uses one fifth of the user's contracted weekly hours" do
      user = build(:user, contracted_hours: 37, working_days_per_week: 4)

      expect(described_class.default_credited_minutes_for(user)).to eq(444)
    end
  end

  describe "credited time parts" do
    it "stores hours and minutes as total credited minutes" do
      user = create(:user)
      day_credit = user.day_credits.create!(
        credit_date: Date.new(2025, 3, 3),
        credit_type: "annual_leave",
        credited_hours_part: "7",
        credited_minutes_part: "24"
      )

      expect(day_credit.credited_minutes).to eq(444)
    end
  end
end
