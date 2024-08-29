class TimeEntry < ApplicationRecord
  validates :clock_in, :clock_out, presence: true

  def hours_worked
    return 0 unless clock_in && clock_out
    total_hours = (clock_out - clock_in) / 1.hour
    total_hours - lunch_duration
  end

  def lunch_duration
    return 0 unless lunch_out && lunch_in
    (lunch_out - lunch_in) / 1.hour
  end

  def lunch_duration_in_hours_and_minutes
    return "0h 0m" unless lunch_out && lunch_in
    
    # Calculate the duration in hours (as a float)
    duration_in_hours = (lunch_out - lunch_in) / 1.hour
    
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

  def self.total_hours_for_week(start_date)
    week_start = start_date.beginning_of_week
    week_end = start_date.end_of_week
    total_hours = where(clock_in: week_start..week_end).sum(&:hours_worked)
    total_hours.round(2)
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

  def self.hours_difference_for_week(start_date)
    (total_hours_for_week(start_date) - 37).round(2)
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
