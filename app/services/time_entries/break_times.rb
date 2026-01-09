module TimeEntries
  class BreakTimes
    def self.apply(time_entry)
      new(time_entry).apply
    end

    def initialize(time_entry)
      @time_entry = time_entry
    end

    def apply
      clock_in = time_entry.clock_in
      return time_entry unless clock_in

      base_date = clock_in.to_date
      crosses_midnight = time_entry.clock_out&.to_date && time_entry.clock_out.to_date > base_date

      time_entry.time_entry_breaks.each do |break_entry|
        next if break_entry.marked_for_destruction?

        break_in_time = break_entry.break_in_time.to_s.strip
        break_out_time = break_entry.break_out_time.to_s.strip

        break_entry.break_in = nil if break_in_time.blank?
        break_entry.break_out = nil if break_out_time.blank?

        next if break_in_time.blank? && break_out_time.blank?

        if break_in_time.present?
          break_entry.break_in = build_break_datetime(base_date, break_in_time, clock_in, crosses_midnight)
        end

        if break_out_time.present?
          break_entry.break_out = build_break_datetime(base_date, break_out_time, clock_in, crosses_midnight)
        end
      end

      time_entry
    end

    private

    attr_reader :time_entry

    def build_break_datetime(base_date, time_string, clock_in, crosses_midnight)
      parts = time_string.split(":").map(&:to_i)
      return if parts.size < 2

      hour = parts[0]
      minute = parts[1]
      second = parts[2] || 0

      date_time = Time.zone.local(base_date.year, base_date.month, base_date.day, hour, minute, second)
      date_time += 1.day if crosses_midnight && date_time < clock_in
      date_time
    end
  end
end
