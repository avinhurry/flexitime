module TimeEntries
  class Defaults
    DEFAULT_WORKING_DAYS = 5
    DEFAULT_MINUTES_PER_DAY = 8 * 60

    def self.apply(time_entry, user:)
      new(time_entry, user).apply
    end

    def initialize(time_entry, user)
      @time_entry = time_entry
      @user = user
    end

    def apply
      return time_entry if times_already_set?

      clock_in = Time.zone.now.change(sec: 0)
      time_entry.clock_in = clock_in
      time_entry.clock_out = clock_in + minutes_per_day.minutes
      time_entry
    end

    private

    attr_reader :time_entry, :user

    def times_already_set?
      time_entry.clock_in || time_entry.clock_out || time_entry.lunch_in || time_entry.lunch_out
    end

    def minutes_per_day
      working_days = user.working_days_per_week.to_i
      working_days = DEFAULT_WORKING_DAYS if working_days <= 0

      contracted_hours = user.contracted_hours.to_f
      minutes = (contracted_hours * 60 / working_days).round
      minutes <= 0 ? DEFAULT_MINUTES_PER_DAY : minutes
    end
  end
end
