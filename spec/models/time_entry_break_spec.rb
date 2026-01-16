require "rails_helper"

RSpec.describe TimeEntryBreak, type: :model do
  describe "validations" do
    it "requires a start time before an end time" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )

      break_entry = entry.time_entry_breaks.build(break_out: Time.zone.local(2025, 3, 7, 12))

      expect(break_entry).not_to be_valid
      expect(break_entry.errors.full_messages).to include("Break end time can't be set without a start time")
    end

    it "allows a break in progress" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )

      break_entry = entry.time_entry_breaks.build(break_in: Time.zone.local(2025, 3, 7, 12))

      expect(break_entry).to be_valid
    end
  end


  describe "#break_in_time" do
    it "prefers the assigned accessor over persisted time" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )

      break_entry = entry.time_entry_breaks.build(break_in: Time.zone.local(2025, 3, 7, 12))
      expect(break_entry.break_in_time).to eq("12:00")

      break_entry.break_in_time = ""
      expect(break_entry.break_in_time).to eq("")
    end
  end
  describe "#duration_in_minutes" do
    it "rounds to the nearest minute" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )

      break_entry = entry.time_entry_breaks.create!(
        break_in: Time.zone.local(2025, 3, 7, 12, 0, 30),
        break_out: Time.zone.local(2025, 3, 7, 12, 31, 0)
      )

      expect(break_entry.duration_in_minutes).to eq(31)
    end
  end
end
