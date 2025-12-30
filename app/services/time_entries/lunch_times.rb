module TimeEntries
  class LunchTimes
    def self.apply(time_entry)
      new(time_entry).apply
    end

    def initialize(time_entry)
      @time_entry = time_entry
    end

    def apply
      lunch_in_time = time_entry.lunch_in_time.to_s.strip
      lunch_out_time = time_entry.lunch_out_time.to_s.strip

      time_entry.lunch_in = nil if lunch_in_time.blank?
      time_entry.lunch_out = nil if lunch_out_time.blank?

      return time_entry if lunch_in_time.blank? && lunch_out_time.blank?

      clock_in = time_entry.clock_in
      return time_entry unless clock_in

      base_date = clock_in.to_date
      crosses_midnight = time_entry.clock_out&.to_date && time_entry.clock_out.to_date > base_date

      if lunch_in_time.present?
        time_entry.lunch_in = build_lunch_datetime(base_date, lunch_in_time, clock_in, crosses_midnight)
      end

      if lunch_out_time.present?
        time_entry.lunch_out = build_lunch_datetime(base_date, lunch_out_time, clock_in, crosses_midnight)
      end

      time_entry
    end

    private

    attr_reader :time_entry

    def build_lunch_datetime(base_date, time_string, clock_in, crosses_midnight)
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
