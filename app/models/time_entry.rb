class TimeEntry < ApplicationRecord
  WORK_WEEK_DAYS = 7
  WORK_WEEK_START = :monday

  belongs_to :user
  has_many :time_entry_breaks, dependent: :destroy

  accepts_nested_attributes_for :time_entry_breaks,
    allow_destroy: true,
    reject_if: ->(attrs) { attrs.values_at("break_in_time", "break_out_time", "reason").all?(&:blank?) }

  validates :clock_in, :clock_out, presence: true

  after_save :recalculate_week_entries
  after_destroy :recalculate_week_entries

  def self.work_week_range(date)
    week_start = date.beginning_of_week(WORK_WEEK_START)
    week_end = week_start + WORK_WEEK_DAYS.days
    week_start...week_end
  end

  def minutes_worked
    return 0 unless clock_in && clock_out

    total_minutes = ((clock_out - clock_in) / 1.minute).round
    total_minutes - breaks_duration_in_minutes
  end

  def hours_worked
    minutes_worked / 60.0
  end

  def breaks_duration_in_minutes
    time_entry_breaks.sum(&:duration_in_minutes)
  end

  def breaks_duration_in_hours_and_minutes
    duration_in_minutes = breaks_duration_in_minutes
    hours = (duration_in_minutes / 60).floor
    minutes = (duration_in_minutes % 60).round

    if minutes == 60
      hours += 1
      minutes = 0
    end

    "#{hours}h #{minutes}m"
  end

  def break_reasons
    time_entry_breaks.filter_map { |break_entry| break_entry.reason.to_s.strip.presence }
  end

  def self.total_hours_for_week(start_date, user)
    range = work_week_range(start_date)
    user.time_entries.where(clock_in: range).sum(&:hours_worked).round(2)
  end

  def self.format_decimal_hours_to_hours_minutes(decimal_hours)
    sign = decimal_hours.negative? ? "-" : ""
    value = decimal_hours.abs
    hours = value.to_i
    minutes = ((value - hours) * 60).round
    if minutes == 60
      hours += 1
      minutes = 0
    end
    "#{sign}#{hours}h #{minutes}m"
  end

  def hours_worked_in_hours_and_minutes
    self.class.format_decimal_hours_to_hours_minutes(hours_worked)
  end

  private

  def recalculate_week_entries
    return unless user && clock_in

    week_starts = [ self.class.work_week_range(clock_in).begin ]
    if saved_change_to_clock_in?
      previous_clock_in = clock_in_before_last_save
      week_starts << self.class.work_week_range(previous_clock_in).begin if previous_clock_in
    end

    week_start = week_starts.min
    WeekEntry.recalculate_from!(user, week_start) if week_start
  end
end
