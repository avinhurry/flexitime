require "rails_helper"

RSpec.describe TimeEntries::Breaks do
  describe ".start" do
    it "creates a break when none is in progress" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )

      result = described_class.start(entry)

      expect(result.ok).to be(true)
      expect(result.message).to be_nil
      expect(entry.reload.break_in_progress?).to be(true)
    end

    it "returns an error when a break is already in progress" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )
      entry.time_entry_breaks.create!(break_in: Time.zone.local(2025, 3, 7, 12))

      result = described_class.start(entry)

      expect(result.ok).to be(false)
      expect(result.message).to eq("A break is already in progress.")
    end
  end

  describe ".end" do
    it "ends the current break" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )
      entry.time_entry_breaks.create!(break_in: Time.zone.local(2025, 3, 7, 12))

      result = described_class.end(entry)

      expect(result.ok).to be(true)
      expect(result.message).to be_nil
      expect(entry.reload.break_in_progress?).to be(false)
    end

    it "returns an error when no break is in progress" do
      entry = create(:user, email: "user@example.com").time_entries.create!(
        clock_in: Time.zone.local(2025, 3, 7, 9),
        clock_out: Time.zone.local(2025, 3, 7, 17)
      )

      result = described_class.end(entry)

      expect(result.ok).to be(false)
      expect(result.message).to eq("No break in progress.")
    end
  end
end
