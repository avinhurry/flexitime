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
    context "when lunch is recorded" do
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

    context "when clock times are missing" do
      it "returns zero minutes" do
        entry = described_class.new
        expect(entry.minutes_worked).to eq(0)
      end
    end

    context "when lunch is not recorded" do
      it "does not subtract lunch minutes" do
        user = create(:user, email: "user@example.com")
        date = Date.new(2025, 3, 3)

        entry = create_entry(user, date, start_hour: 9, end_hour: 17)

        expect(entry.minutes_worked).to eq(480)
      end
    end
  end

  describe "#lunch_duration_in_minutes" do
    context "when lunch is missing" do
      it "returns zero" do
        entry = described_class.new
        expect(entry.lunch_duration_in_minutes).to eq(0)
      end
    end

    context "when lunch has seconds" do
      it "rounds to the nearest minute" do
        user = create(:user, email: "user@example.com")
        date = Date.new(2025, 3, 3)
        clock_in = Time.zone.local(date.year, date.month, date.day, 9)
        clock_out = Time.zone.local(date.year, date.month, date.day, 17)
        lunch_in = Time.zone.local(date.year, date.month, date.day, 12, 0, 30)
        lunch_out = Time.zone.local(date.year, date.month, date.day, 12, 31, 0)

        entry = user.time_entries.create!(
          clock_in: clock_in,
          clock_out: clock_out,
          lunch_in: lunch_in,
          lunch_out: lunch_out
        )

        expect(entry.lunch_duration_in_minutes).to eq(31)
      end
    end
  end

  describe "#lunch_duration_in_hours_and_minutes" do
    it "formats hours and minutes" do
      user = create(:user, email: "user@example.com")
      date = Date.new(2025, 3, 3)
      entry = user.time_entries.create!(
        clock_in: Time.zone.local(date.year, date.month, date.day, 9),
        clock_out: Time.zone.local(date.year, date.month, date.day, 17),
        lunch_in: Time.zone.local(date.year, date.month, date.day, 12),
        lunch_out: Time.zone.local(date.year, date.month, date.day, 12, 45)
      )

      expect(entry.lunch_duration_in_hours_and_minutes).to eq("0h 45m")
    end
  end

  describe ".total_hours_for_week" do
    context "when multiple users have entries" do
      it "scopes to the user" do
        user = create(:user, email: "user@example.com")
        other = create(:user, email: "other@example.com")
        date = Date.new(2025, 3, 3)

        create_entry(user, date, start_hour: 9, end_hour: 17)
        create_entry(other, date, start_hour: 9, end_hour: 17)

        expect(TimeEntry.total_hours_for_week(date, user)).to be_within(0.01).of(8.0)
      end
    end

    context "when entries exist outside the week" do
      it "only totals entries inside the week range" do
        user = create(:user, email: "user@example.com")
        week_start = Date.new(2025, 3, 3)
        next_week = week_start + 7.days

        create_entry(user, week_start, start_hour: 9, end_hour: 17)
        create_entry(user, next_week, start_hour: 9, end_hour: 17)

        expect(TimeEntry.total_hours_for_week(week_start, user)).to be_within(0.01).of(8.0)
      end
    end
  end

  describe ".format_decimal_hours_to_hours_minutes" do
    context "when the value rounds to the next hour" do
      it "rolls minutes into hours" do
        expect(described_class.format_decimal_hours_to_hours_minutes(1.999)).to eq("2h 0m")
      end
    end

    context "when the value is negative" do
      it "preserves the sign" do
        expect(described_class.format_decimal_hours_to_hours_minutes(-0.5)).to eq("-0h 30m")
      end
    end
  end

  describe ".work_week_range" do
    it "starts on Monday and spans seven days" do
      date = Date.new(2025, 3, 5)
      range = described_class.work_week_range(date)

      expect(range.begin).to eq(date.beginning_of_week(:monday))
      expect(range.end).to eq(range.begin + 7.days)
    end
  end
end
