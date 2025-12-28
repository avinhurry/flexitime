class TimeEntry < ApplicationRecord
  belongs_to :user

  validates :clock_in, :clock_out, presence: true

  after_save { update_after_save }

  def update_after_save
    start_date = self.clock_in
    week_start = start_date.beginning_of_week
    week_end = start_date.end_of_week

    working_week = TimeEntry.where(clock_in: week_start..week_end)
    working_week_minutes = working_week.sum(&:minutes_worked)
    first_working_day = working_week.first
    week_entry = first_working_day.user.week_entries.find_or_initialize_by(beginning_of_week: week_start)
    user = first_working_day.user
    contracted_hours = user.contracted_hours

    offset_minutes = working_week_minutes - (contracted_hours * 60)
 
    week_entry.update(offset_in_minutes: offset_minutes)
  end

  def minutes_worked
    return 0 unless clock_in && clock_out
    total_minutes = (clock_out - clock_in)
    (total_minutes - lunch_duration)/1.minute
  end

  def hours_worked
    minutes_worked / 60
  end

  def lunch_duration_in_minutes
    return 0 unless lunch_out && lunch_in
    (lunch_out - lunch_in)
  end

  def lunch_duration
    lunch_duration_in_minutes/60
  end

  def lunch_duration_in_hours_and_minutes
    return "0h 0m" unless lunch_out && lunch_in

    # Calculate the duration in hours (as a float)
    duration_in_hours = (lunch_out - lunch_in) / 60

    # Convert the float into hours and minutes
    hours = duration_in_hours.floor
    minutes = ((duration_in_hours - hours) * 60).round

    # Adjust if minutes reach 60
    if minutes == 60
      hours += 1
      minutes = 0
    end

    "#{hours}h #{minutes}m"
  end

  def self.total_hours_for_week(start_date, user)
    week_start = start_date.beginning_of_week(:monday)
    week_end = week_start + 4.days

    where(user: user, clock_in: week_start..week_end).sum(&:hours_worked).round(2)
  end


  def self.total_hours_for_week(start_date, user)
  week_start = start_date.beginning_of_week(:monday)
  week_end = week_start + 4.days

  where(user: user, clock_in: week_start..week_end).sum(&:hours_worked).round(2)
end

  def self.format_decimal_hours_to_hours_minutes(decimal_hours)
    hours = decimal_hours.to_i
    minutes = ((decimal_hours - hours) * 60).round
    # Handle edge case where minutes might be 60
    if minutes == 60
      hours += 1
      minutes = 0
    end
    "#{hours}h #{minutes}m"
  end

  def hours_worked_in_hours_and_minutes
    return "0h 0m" unless hours_worked

    hours = hours_worked.to_i
    minutes = ((hours_worked - hours) * 60).round

    # Handle cases where minutes might be rounded to 60
    if minutes == 60
      hours += 1
      minutes = 0
    end

    "#{hours}h #{minutes}m"
  end
end
