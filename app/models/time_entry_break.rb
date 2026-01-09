class TimeEntryBreak < ApplicationRecord
  belongs_to :time_entry

  attr_accessor :break_in_time, :break_out_time

  validate :break_times_complete

  def duration_in_minutes
    return 0 unless break_in && break_out

    ((break_out - break_in) / 1.minute).round
  end

  def break_in_time
    return @break_in_time if instance_variable_defined?(:@break_in_time)

    break_in&.strftime("%H:%M")
  end

  def break_out_time
    return @break_out_time if instance_variable_defined?(:@break_out_time)

    break_out&.strftime("%H:%M")
  end

  private

  def break_times_complete
    return if break_in.blank? && break_out.blank?
    return if break_in.present? && break_out.present?

    errors.add(:base, "Break start and end must both be set")
  end
end
