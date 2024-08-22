class TimeEntry < ApplicationRecord
  def hours_worked
    return 0 unless clock_in && clock_out
    ((clock_out - clock_in) / 1.hour).round(2)
  end

  def self.total_hours_for_week(week_start)
    where(clock_in: week_start.beginning_of_week..week_start.end_of_week).sum(&:hours_worked)
  end

  def self.hours_difference_for_week(week_start, contracted_hours = 37)
    total_hours = total_hours_for_week(week_start)
    (total_hours - contracted_hours).round(2)
  end
end
