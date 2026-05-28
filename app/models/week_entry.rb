class WeekEntry < ApplicationRecord
  belongs_to :user

  validates :beginning_of_week, presence: true
  validates :offset_in_minutes, numericality: { only_integer: true }, allow_nil: true
  validates :required_minutes, numericality: { only_integer: true }

  before_validation :normalize_beginning_of_week
  before_create :set_required_minutes

  def self.required_minutes_for(user, week_start)
    normalized_week_start = normalize_week_start(week_start)
    existing = user.week_entries.find_by(beginning_of_week: normalized_week_start)
    return existing.required_minutes if existing

    previous_entry = user.week_entries.where("beginning_of_week < ?", normalized_week_start)
      .order(beginning_of_week: :desc).first
    required_minutes_from_previous(user, previous_entry)
  end

  def self.recalculate_from!(user, week_start)
    normalized_week_start = normalize_week_start(week_start)
    contracted_minutes = user.contracted_hours.to_i * 60

    remove_inactive_week_entries_from!(user, normalized_week_start)
    ensure_week_entries_for_activity_from!(user, normalized_week_start)

    previous_entry = user.week_entries.where("beginning_of_week < ?", normalized_week_start)
      .order(beginning_of_week: :desc).first
    previous_offset = previous_entry&.offset_in_minutes.to_i

    user.week_entries.where("beginning_of_week >= ?", normalized_week_start)
      .order(:beginning_of_week)
      .each do |entry|
        range = TimeEntry.work_week_range(entry.beginning_of_week)
        week_minutes = user.time_entries.where(clock_in: range).sum(&:minutes_worked)
        credited_minutes = DayCredit.total_minutes_for_week(entry.beginning_of_week, user)
        week_delta = week_minutes + credited_minutes - contracted_minutes
        # Offset is cumulative (prior balance + this week's).
        entry.required_minutes = contracted_minutes - previous_offset
        entry.offset_in_minutes = previous_offset + week_delta
        entry.save!
        previous_offset = entry.offset_in_minutes
      end
  end

  def self.required_minutes_from_previous(user, previous_entry)
    contracted_minutes = user.contracted_hours.to_i * 60
    contracted_minutes - previous_entry&.offset_in_minutes.to_i
  end

  def self.normalize_week_start(week_start)
    TimeEntry.work_week_start(week_start)
  end

  def self.ensure_week_entries_for_activity_from!(user, normalized_week_start)
    week_starts = active_week_starts_from(user, normalized_week_start)

    week_starts.each do |activity_week_start|
      user.week_entries.find_or_create_by!(beginning_of_week: activity_week_start)
    end
  end

  def self.remove_inactive_week_entries_from!(user, normalized_week_start)
    user.week_entries.where("beginning_of_week >= ?", normalized_week_start).find_each do |entry|
      entry.destroy! unless week_has_activity?(user, entry.beginning_of_week)
    end
  end

  def self.active_week_starts_from(user, normalized_week_start)
    time_entry_week_starts = user.time_entries
      .where("clock_in >= ?", normalized_week_start)
      .pluck(:clock_in)
      .map { |clock_in| normalize_week_start(clock_in) }

    day_credit_week_starts = user.day_credits
      .where("credit_date >= ?", normalized_week_start.to_date)
      .pluck(:credit_date)
      .map { |credit_date| normalize_week_start(credit_date) }

    (time_entry_week_starts + day_credit_week_starts).uniq.sort
  end

  def self.week_has_activity?(user, week_start)
    user.time_entries.where(clock_in: TimeEntry.work_week_range(week_start)).exists? ||
      DayCredit.for_week(user, week_start).exists?
  end

  private

  def normalize_beginning_of_week
    return if beginning_of_week.blank?

    self.beginning_of_week = self.class.normalize_week_start(beginning_of_week)
  end

  def set_required_minutes
    previous_entry = user.week_entries.where("beginning_of_week < ?", beginning_of_week)
      .order(beginning_of_week: :desc).first
    self.required_minutes = self.class.required_minutes_from_previous(user, previous_entry)
  end
end
