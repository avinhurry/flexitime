class WeekEntry < ApplicationRecord
  belongs_to :user

  validates :beginning_of_week, presence: true
  validates :offset_in_minutes, numericality: { only_integer: true }, allow_nil: true
  validates :required_minutes, numericality: { only_integer: true }

  before_create :set_required_minutes

  def self.required_minutes_for(user, week_start)
    normalized_week_start = week_start.beginning_of_week(:monday)
    existing = user.week_entries.find_by(beginning_of_week: normalized_week_start)
    return existing.required_minutes if existing

    previous_entry = user.week_entries.where("beginning_of_week < ?", normalized_week_start)
      .order(beginning_of_week: :desc).first
    required_minutes_from_previous(user, previous_entry)
  end

  def self.recalculate_from!(user, week_start)
    normalized_week_start = week_start.beginning_of_week(:monday)
    contracted_minutes = user.contracted_hours.to_i * 60

    current_range = TimeEntry.work_week_range(normalized_week_start)
    working_week = user.time_entries.where(clock_in: current_range)

    if working_week.exists?
      user.week_entries.find_or_create_by!(beginning_of_week: normalized_week_start)
    else
      user.week_entries.where(beginning_of_week: normalized_week_start).delete_all
    end

    previous_entry = user.week_entries.where("beginning_of_week < ?", normalized_week_start)
      .order(beginning_of_week: :desc).first
    previous_offset = previous_entry&.offset_in_minutes.to_i

    user.week_entries.where("beginning_of_week >= ?", normalized_week_start)
      .order(:beginning_of_week)
      .each do |entry|
        range = TimeEntry.work_week_range(entry.beginning_of_week)
        week_minutes = user.time_entries.where(clock_in: range).sum(&:minutes_worked)
        week_delta = week_minutes - contracted_minutes
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

  private

  def set_required_minutes
    previous_entry = user.week_entries.where("beginning_of_week < ?", beginning_of_week)
      .order(beginning_of_week: :desc).first
    self.required_minutes = self.class.required_minutes_from_previous(user, previous_entry)
  end
end
