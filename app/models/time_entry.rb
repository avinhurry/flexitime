class TimeEntry < ApplicationRecord
  validates :clock_in, :clock_out, presence: true

  def hours_worked
    return 0 unless clock_in && clock_out
    total_hours = (clock_out - clock_in) / 1.hour
    total_hours - (lunch_duration || 0)
  end

  def self.total_hours_for_week(start_date)
    where(clock_in: start_date.beginning_of_week..start_date.end_of_week).sum(&:hours_worked).round(2)
  end
  
  def self.hours_difference_for_week(start_date)
    (total_hours_for_week(start_date) - 37).round(2)
  end
end
