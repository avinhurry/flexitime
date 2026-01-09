require "rails_helper"

RSpec.describe TimeEntries::BreakTimes do
  describe ".apply" do
    it "sets break times on the clock-in date" do
      clock_in = Time.zone.local(2025, 3, 7, 9, 0)
      clock_out = Time.zone.local(2025, 3, 7, 17, 0)
      entry = TimeEntry.new(clock_in: clock_in, clock_out: clock_out)
      entry.time_entry_breaks.build(
        break_in_time: "12:10",
        break_out_time: "12:40"
      )

      described_class.apply(entry)

      break_entry = entry.time_entry_breaks.first
      expect(break_entry.break_in).to eq(Time.zone.local(2025, 3, 7, 12, 10))
      expect(break_entry.break_out).to eq(Time.zone.local(2025, 3, 7, 12, 40))
    end

    it "rolls break times into the next day when the shift crosses midnight" do
      clock_in = Time.zone.local(2025, 3, 7, 22, 0)
      clock_out = Time.zone.local(2025, 3, 8, 1, 0)
      entry = TimeEntry.new(clock_in: clock_in, clock_out: clock_out)
      entry.time_entry_breaks.build(
        break_in_time: "00:15",
        break_out_time: "00:45"
      )

      described_class.apply(entry)

      break_entry = entry.time_entry_breaks.first
      expect(break_entry.break_in).to eq(Time.zone.local(2025, 3, 8, 0, 15))
      expect(break_entry.break_out).to eq(Time.zone.local(2025, 3, 8, 0, 45))
    end

    it "clears break times when blanks are provided" do
      clock_in = Time.zone.local(2025, 3, 7, 9, 0)
      clock_out = Time.zone.local(2025, 3, 7, 17, 0)
      entry = TimeEntry.new(clock_in: clock_in, clock_out: clock_out)
      entry.time_entry_breaks.build(
        break_in: Time.zone.local(2025, 3, 7, 12, 0),
        break_out: Time.zone.local(2025, 3, 7, 12, 30),
        break_in_time: "",
        break_out_time: ""
      )

      described_class.apply(entry)

      break_entry = entry.time_entry_breaks.first
      expect(break_entry.break_in).to be_nil
      expect(break_entry.break_out).to be_nil
    end
  end
end
