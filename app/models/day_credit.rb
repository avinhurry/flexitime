class DayCredit < ApplicationRecord
  TYPES = {
    "bank_holiday" => "Bank holiday",
    "annual_leave" => "Annual leave",
    "sick_leave" => "Sick leave",
    "other" => "Other"
  }.freeze

  belongs_to :user

  validates :credit_date, presence: true
  validates :credit_type, presence: true, inclusion: { in: TYPES.keys }
  validates :credited_minutes, numericality: { only_integer: true, greater_than: 0 }
  validates :credited_hours_part,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    allow_nil: true
  validates :credited_minutes_part,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 60 },
    allow_nil: true

  before_validation :set_default_credited_minutes
  before_validation :apply_credited_minute_parts

  after_save :recalculate_week_entries
  after_destroy :recalculate_week_entries

  def self.default_credited_minutes_for(user)
    ((user.contracted_hours.to_i * 60) / 5.0).round
  end

  def self.type_options
    TYPES.map { |value, label| [ label, value ] }
  end

  def self.week_date_range(week_start)
    week_range = TimeEntry.work_week_range(week_start)
    week_range.begin.to_date...week_range.end.to_date
  end

  def self.for_week(user, week_start)
    user.day_credits.where(credit_date: week_date_range(week_start)).order(:credit_date, :id)
  end

  def self.total_minutes_for_week(week_start, user)
    for_week(user, week_start).sum(:credited_minutes)
  end

  def type_label
    TYPES.fetch(credit_type)
  end

  def credited_hours_part
    return @credited_hours_part if defined?(@credited_hours_part)

    credited_minutes.to_i / 60
  end

  def credited_hours_part=(value)
    @credited_minute_parts_provided = true
    @credited_hours_part = value.presence
  end

  def credited_minutes_part
    return @credited_minutes_part if defined?(@credited_minutes_part)

    credited_minutes.to_i % 60
  end

  def credited_minutes_part=(value)
    @credited_minute_parts_provided = true
    @credited_minutes_part = value.presence
  end

  private

  def set_default_credited_minutes
    self.credited_minutes ||= self.class.default_credited_minutes_for(user) if user
  end

  def apply_credited_minute_parts
    return unless @credited_minute_parts_provided

    self.credited_minutes = credited_hours_part.to_i * 60 + credited_minutes_part.to_i
  end

  def recalculate_week_entries
    return unless user && credit_date

    week_starts = [ TimeEntry.work_week_start(credit_date) ]
    if saved_change_to_credit_date?
      previous_credit_date = credit_date_before_last_save
      week_starts << TimeEntry.work_week_start(previous_credit_date) if previous_credit_date
    end

    WeekEntry.recalculate_from!(user, week_starts.min)
  end
end
