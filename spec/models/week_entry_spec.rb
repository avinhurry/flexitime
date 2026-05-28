require "rails_helper"

RSpec.describe WeekEntry, type: :model do
  def create_shift(user, date, hours)
    clock_in = Time.zone.local(date.year, date.month, date.day, 9)
    clock_out = clock_in + hours.hours
    user.time_entries.create!(clock_in: clock_in, clock_out: clock_out)
  end

  context "when prior week balances exist" do
    it "carries prior week offset into required minutes and recomputes" do
      user = create(:user, email: "user@example.com")
      week1_start = Date.new(2025, 3, 3)

      4.times do |i|
        create_shift(user, week1_start + i.days, 10)
      end

      week1_entry = user.week_entries.find_by(beginning_of_week: week1_start.beginning_of_week(:monday))
      expect(week1_entry.offset_in_minutes).to eq(180)

      week2_start = week1_start + 7.days
      expected_required = (user.contracted_hours * 60) - 180
      expect(described_class.required_minutes_for(user, week2_start)).to eq(expected_required)

      create_shift(user, week2_start, 8)
      week2_entry = user.week_entries.find_by(beginning_of_week: week2_start.beginning_of_week(:monday))
      expect(week2_entry.required_minutes).to eq(expected_required)

      first_entry = user.time_entries.order(:clock_in).first
      first_entry.update!(clock_out: first_entry.clock_in + 7.hours)

      week2_entry.reload
      expect(week2_entry.required_minutes).to eq(user.contracted_hours * 60)
    end
  end

  context "when no prior week entry exists" do
    it "uses contracted hours as the required minutes" do
      user = create(:user, email: "user@example.com")
      week_start = Date.new(2025, 3, 3)

      expect(described_class.required_minutes_for(user, week_start)).to eq(user.contracted_hours * 60)
    end
  end

  context "when day credits exist" do
    it "includes credited minutes in the weekly balance" do
      user = create(:user, email: "credits@example.com", contracted_hours: 37)
      week_start = Date.new(2025, 3, 3)

      5.times do |i|
        user.day_credits.create!(
          credit_date: week_start + i.days,
          credit_type: "annual_leave",
          credited_minutes: DayCredit.default_credited_minutes_for(user)
        )
      end

      week_entry = user.week_entries.find_by(beginning_of_week: TimeEntry.work_week_start(week_start))

      expect(week_entry).to be_present
      expect(week_entry.offset_in_minutes).to eq(0)
    end

    it "rebuilds week entries when a credit moves to a different week" do
      user = create(:user, email: "moved-credit@example.com", contracted_hours: 37)
      old_week_start = Date.new(2025, 3, 3)
      new_week_start = Date.new(2025, 3, 10)
      day_credit = user.day_credits.create!(
        credit_date: old_week_start,
        credit_type: "annual_leave",
        credited_minutes: DayCredit.default_credited_minutes_for(user)
      )

      day_credit.update!(credit_date: new_week_start)

      expect(user.week_entries.find_by(beginning_of_week: TimeEntry.work_week_start(old_week_start))).to be_nil
      expect(user.week_entries.find_by(beginning_of_week: TimeEntry.work_week_start(new_week_start))).to be_present
    end
  end

  context "across the daylight saving boundary" do
    it "returns the current week's stored target after creating a post-DST entry" do
      user = create(:user, email: "dst@example.com")
      previous_week_start = Date.new(2026, 3, 16)

      4.times do |i|
        create_shift(user, previous_week_start + i.days, 10)
      end

      current_week_start = Date.new(2026, 4, 6)
      required_before = described_class.required_minutes_for(user, current_week_start)

      create_shift(user, current_week_start, 8)

      current_entry = user.week_entries.find_by(beginning_of_week: TimeEntry.work_week_start(current_week_start))

      expect(current_entry.required_minutes).to eq(required_before)
      expect(described_class.required_minutes_for(user, current_week_start)).to eq(required_before)
    end
  end

  context "when a week entry already exists" do
    it "returns the stored required minutes" do
      user = create(:user, email: "user@example.com")
      week_start = Date.new(2025, 3, 3).beginning_of_week(:monday)
      entry = user.week_entries.create!(beginning_of_week: week_start, required_minutes: 120)

      expect(described_class.required_minutes_for(user, week_start)).to eq(entry.required_minutes)
    end
  end

  context "when the last entry in a week is removed" do
    it "removes the week entry" do
      user = create(:user, email: "user@example.com")
      week_start = Date.new(2025, 3, 3)

      entry = create_shift(user, week_start, 8)
      expect(user.week_entries.find_by(beginning_of_week: week_start.beginning_of_week(:monday))).to be_present

      entry.destroy

      expect(user.week_entries.find_by(beginning_of_week: week_start.beginning_of_week(:monday))).to be_nil
    end
  end
end
