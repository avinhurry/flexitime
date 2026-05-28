require "rails_helper"

RSpec.describe DayCreditsHelper, type: :helper do
  describe "#day_credit_amount_options" do
    it "returns standard, half, and custom options" do
      day_credit = build(:day_credit, user: build(:user, contracted_hours: 37))

      expect(helper.day_credit_amount_options(day_credit)).to eq(
        [
          [ "Standard day · 7h 24m", "standard" ],
          [ "Half day · 3h 42m", "half" ],
          [ "Custom", "custom" ]
        ]
      )
    end
  end

  describe "#selected_day_credit_amount" do
    it "selects standard when credited minutes match the standard day" do
      day_credit = build(:day_credit, user: build(:user, contracted_hours: 37), credited_minutes: 444)

      expect(helper.selected_day_credit_amount(day_credit)).to eq("standard")
    end

    it "selects half when credited minutes match the half day" do
      day_credit = build(:day_credit, user: build(:user, contracted_hours: 37), credited_minutes: 222)

      expect(helper.selected_day_credit_amount(day_credit)).to eq("half")
    end

    it "selects custom for any other credited minutes" do
      day_credit = build(:day_credit, user: build(:user, contracted_hours: 37), credited_minutes: 60)

      expect(helper.selected_day_credit_amount(day_credit)).to eq("custom")
    end
  end

  describe "#day_credit_amount_controller_data" do
    it "returns the Stimulus controller values for the amount selector" do
      day_credit = build(:day_credit, user: build(:user, contracted_hours: 37))

      expect(helper.day_credit_amount_controller_data(day_credit)).to eq(
        {
          controller: "day-credit-amount",
          day_credit_amount_standard_minutes_value: 444,
          day_credit_amount_half_minutes_value: 222
        }
      )
    end
  end

  describe "#password_manager_ignore_data" do
    it "returns 1Password ignore attributes" do
      expect(helper.password_manager_ignore_data).to eq(
        { "1p-ignore": true, "op-ignore": true }
      )
    end
  end
end
