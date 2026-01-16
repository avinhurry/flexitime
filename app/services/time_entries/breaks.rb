module TimeEntries
  class Breaks
    Result = Struct.new(:ok, :message, keyword_init: true)

    def self.start(time_entry)
      if time_entry.break_in_progress?
        return Result.new(ok: false, message: "A break is already in progress.")
      end

      time_entry.time_entry_breaks.create!(break_in: Time.zone.now)
      Result.new(ok: true, message: nil)
    end

    def self.end(time_entry)
      break_entry = time_entry.current_break
      return Result.new(ok: false, message: "No break in progress.") unless break_entry

      break_entry.update!(break_out: Time.zone.now)
      Result.new(ok: true, message: nil)
    end
  end
end
