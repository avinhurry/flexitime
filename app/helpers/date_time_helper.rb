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
end
