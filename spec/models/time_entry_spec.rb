require "rails_helper"

RSpec.describe TimeEntry, type: :model do
  def create_entry(user, date, start_hour:, start_minute: 0, end_hour:, end_minute: 0, lunch: nil)
    clock_in = Time.zone.local(date.year, date.month, date.day, start_hour, start_minute)
    clock_out = Time.zone.local(date.year, date.month, date.day, end_hour, end_minute)
    attrs = { clock_in: clock_in, clock_out: clock_out }

    if lunch
      lunch_in = Time.zone.local(date.year, date.month, date.day, lunch[:start_hour], lunch.fetch(:start_minute, 0))
      lunch_out = Time.zone.local(date.year, date.month, date.day, lunch[:end_hour], lunch.fetch(:end_minute, 0))
      attrs.merge!(lunch_in: lunch_in, lunch_out: lunch_out)
    end

    user.time_entries.create!(attrs)
  end

  describe "#minutes_worked" do
    it "subtracts lunch in minutes" do
      user = create(:user, email: "user@example.com")
      date = Date.new(2025, 3, 3)

      entry = create_entry(
        user,
        date,
        start_hour: 9,
        end_hour: 17,
        lunch: { start_hour: 12, end_hour: 12, end_minute: 30 }
      )

      expect(entry.minutes_worked).to eq(450)
      expect(entry.hours_worked).to be_within(0.01).of(7.5)
    end
  end

  describe ".total_hours_for_week" do
    it "scopes to the user" do
      user = create(:user, email: "user@example.com")
      other = create(:user, email: "other@example.com")
      date = Date.new(2025, 3, 3)

      create_entry(user, date, start_hour: 9, end_hour: 17)
      create_entry(other, date, start_hour: 9, end_hour: 17)

      expect(TimeEntry.total_hours_for_week(date, user)).to be_within(0.01).of(8.0)
    end
  end
end
