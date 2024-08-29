class TimeEntry < ApplicationRecord
  validates :clock_in, :clock_out, presence: true

  def hours_worked
    return 0 unless clock_in && clock_out
    total_hours = (clock_out - clock_in) / 1.hour
    total_hours - lunch_duration
  end

  def lunch_duration
    return 0 unless lunch_out && lunch_in
    (lunch_in - lunch_out) / 1.hour
  end

  def self.total_hours_for_week(start_date)
    where(clock_in: start_date.beginning_of_week..start_date.end_of_week).sum(&:hours_worked).round(2)
  end
  
  def self.hours_difference_for_week(start_date)
    (total_hours_for_week(start_date) - 37).round(2)
  end

  def hours_worked_in_hours_and_minutes
    return "0h 0m" unless hours_worked

    total_hours = hours_worked
    hours = total_hours.floor
    minutes = ((total_hours - hours) * 60).round

    # If minutes are 60, it means we need to adjust hours and minutes
    if minutes == 60
      hours += 1
      minutes = 0
    end

    "#{hours}h #{minutes}m"
  end
end
