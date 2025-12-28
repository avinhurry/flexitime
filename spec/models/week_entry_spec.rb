require "rails_helper"

RSpec.describe WeekEntry, type: :model do
  def create_shift(user, date, hours)
    clock_in = Time.zone.local(date.year, date.month, date.day, 9)
    clock_out = clock_in + hours.hours
    user.time_entries.create!(clock_in: clock_in, clock_out: clock_out)
  end

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
    expect(WeekEntry.required_minutes_for(user, week2_start)).to eq(expected_required)

    create_shift(user, week2_start, 8)
    week2_entry = user.week_entries.find_by(beginning_of_week: week2_start.beginning_of_week(:monday))
    expect(week2_entry.required_minutes).to eq(expected_required)

    first_entry = user.time_entries.order(:clock_in).first
    first_entry.update!(clock_out: first_entry.clock_in + 7.hours)

    week2_entry.reload
    expect(week2_entry.required_minutes).to eq(user.contracted_hours * 60)
  end
end
