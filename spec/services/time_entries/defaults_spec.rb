require "rails_helper"

RSpec.describe TimeEntries::Defaults do
  describe ".apply" do
    it "prefills clock in and clock out from contracted hours and working days" do
      user = build(:user, contracted_hours: 37, working_days_per_week: 4)
      entry = TimeEntry.new

      travel_to Time.zone.local(2025, 3, 7, 9, 15) do
        described_class.apply(entry, user: user)
      end

      expected_clock_in = Time.zone.local(2025, 3, 7, 9, 15).change(sec: 0)
      expect(entry.clock_in).to eq(expected_clock_in)
      expect(entry.clock_out).to eq(expected_clock_in + 9.hours + 15.minutes)
    end

    it "does not override existing times" do
      user = build(:user, contracted_hours: 37, working_days_per_week: 4)
      clock_in = Time.zone.local(2025, 3, 7, 8, 0)
      entry = TimeEntry.new(clock_in: clock_in)

      travel_to Time.zone.local(2025, 3, 7, 9, 15) do
        described_class.apply(entry, user: user)
      end

      expect(entry.clock_in).to eq(clock_in)
      expect(entry.clock_out).to be_nil
    end
  end
end
