module DateTimeHelper
  def format_date(date)
    return "" unless date

    date.to_date.strftime("%-d %b %Y")
  end

  def format_time(time)
    return "" unless time

    time.strftime("%H:%M")
  end

  def format_datetime(time)
    return "" unless time

    time.strftime("%-d %b %Y, %H:%M")
  end

  def breaks_duration_label(time_entry)
    return "No breaks recorded" unless time_entry.time_entry_breaks.any?

    minutes = time_entry.breaks_duration_in_minutes.to_i
    return "<1m" if minutes.zero?

    time_entry.breaks_duration_in_hours_and_minutes
  end
end
