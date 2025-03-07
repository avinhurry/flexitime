class WeekEntry < ApplicationRecord
  belongs_to :user

  before_create :set_required_minutes

  def set_required_minutes
    previous_week = user.week_entries.where("beginning_of_week < ?", beginning_of_week).order(beginning_of_week: :desc).first

    return if previous_week.nil?

    previous_offset = previous_week&.offset_in_minutes.to_i

    self.required_minutes = previous_offset.abs
  end
end
