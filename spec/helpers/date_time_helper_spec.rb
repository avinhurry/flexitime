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

  describe "#breaks_duration_label" do
    it "returns a fallback when no breaks exist" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 12, 29, 9, 0),
        clock_out: Time.zone.local(2025, 12, 29, 17, 0)
      )

      expect(helper.breaks_duration_label(entry)).to eq("No breaks recorded")
    end

    it "returns <1m for very short breaks" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 12, 29, 9, 0),
        clock_out: Time.zone.local(2025, 12, 29, 17, 0)
      )
      entry.time_entry_breaks.create!(
        break_in: Time.zone.local(2025, 12, 29, 12, 0, 30),
        break_out: Time.zone.local(2025, 12, 29, 12, 0, 50)
      )

      expect(helper.breaks_duration_label(entry)).to eq("<1m")
    end

    it "returns the formatted duration for longer breaks" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 12, 29, 9, 0),
        clock_out: Time.zone.local(2025, 12, 29, 17, 0)
      )
      entry.time_entry_breaks.create!(
        break_in: Time.zone.local(2025, 12, 29, 12, 0),
        break_out: Time.zone.local(2025, 12, 29, 12, 45)
      )

      expect(helper.breaks_duration_label(entry)).to eq("0h 45m")
    end
  end
end
