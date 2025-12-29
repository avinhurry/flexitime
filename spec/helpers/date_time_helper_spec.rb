require "rails_helper"

RSpec.describe DateTimeHelper, type: :helper do
  describe "#format_date" do
    it "returns an empty string for nil" do
      expect(helper.format_date(nil)).to eq("")
    end

    it "formats the date as day month year" do
      date = Date.new(2025, 12, 29)
      expect(helper.format_date(date)).to eq("29 Dec 2025")
    end
  end

  describe "#format_time" do
    it "returns an empty string for nil" do
      expect(helper.format_time(nil)).to eq("")
    end

    it "formats time as 24-hour hours and minutes" do
      time = Time.zone.local(2025, 12, 29, 17, 39)
      expect(helper.format_time(time)).to eq("17:39")
    end
  end

  describe "#format_datetime" do
    it "returns an empty string for nil" do
      expect(helper.format_datetime(nil)).to eq("")
    end

    it "formats datetime as day month year and time" do
      time = Time.zone.local(2025, 12, 29, 17, 39)
      expect(helper.format_datetime(time)).to eq("29 Dec 2025, 17:39")
    end
  end
end
