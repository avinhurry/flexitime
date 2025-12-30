require "rails_helper"

RSpec.describe TimeEntries::LunchTimes do
  describe ".apply" do
    it "sets lunch times on the clock-in date" do
      clock_in = Time.zone.local(2025, 3, 7, 9, 0)
      clock_out = Time.zone.local(2025, 3, 7, 17, 0)
      entry = TimeEntry.new(
        clock_in: clock_in,
        clock_out: clock_out,
        lunch_in_time: "12:10",
        lunch_out_time: "12:40"
      )

      described_class.apply(entry)

      expect(entry.lunch_in).to eq(Time.zone.local(2025, 3, 7, 12, 10))
      expect(entry.lunch_out).to eq(Time.zone.local(2025, 3, 7, 12, 40))
    end

    it "rolls lunch times into the next day when the shift crosses midnight" do
      clock_in = Time.zone.local(2025, 3, 7, 22, 0)
      clock_out = Time.zone.local(2025, 3, 8, 1, 0)
      entry = TimeEntry.new(
        clock_in: clock_in,
        clock_out: clock_out,
        lunch_in_time: "00:15",
        lunch_out_time: "00:45"
      )

      described_class.apply(entry)

      expect(entry.lunch_in).to eq(Time.zone.local(2025, 3, 8, 0, 15))
      expect(entry.lunch_out).to eq(Time.zone.local(2025, 3, 8, 0, 45))
    end

    it "clears lunch times when blanks are provided" do
      clock_in = Time.zone.local(2025, 3, 7, 9, 0)
      clock_out = Time.zone.local(2025, 3, 7, 17, 0)
      entry = TimeEntry.new(
        clock_in: clock_in,
        clock_out: clock_out,
        lunch_in: Time.zone.local(2025, 3, 7, 12, 0),
        lunch_out: Time.zone.local(2025, 3, 7, 12, 30),
        lunch_in_time: "",
        lunch_out_time: ""
      )

      described_class.apply(entry)

      expect(entry.lunch_in).to be_nil
      expect(entry.lunch_out).to be_nil
    end
  end
end
