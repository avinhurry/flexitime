module DayCreditsHelper
  def day_credit_standard_minutes(day_credit)
    DayCredit.default_credited_minutes_for(day_credit.user)
  end

  def day_credit_half_minutes(day_credit)
    (day_credit_standard_minutes(day_credit) / 2.0).round
  end

  def day_credit_amount_options(day_credit)
    [
      [ "Standard day · #{format_minutes_as_hours_minutes(day_credit_standard_minutes(day_credit))}", "standard" ],
      [ "Half day · #{format_minutes_as_hours_minutes(day_credit_half_minutes(day_credit))}", "half" ],
      [ "Custom", "custom" ]
    ]
  end

  def selected_day_credit_amount(day_credit)
    submitted_minutes = day_credit.credited_hours_part.to_i * 60 + day_credit.credited_minutes_part.to_i

    return "standard" if submitted_minutes == day_credit_standard_minutes(day_credit)
    return "half" if submitted_minutes == day_credit_half_minutes(day_credit)

    "custom"
  end

  def day_credit_amount_controller_data(day_credit)
    {
      controller: "day-credit-amount",
      day_credit_amount_standard_minutes_value: day_credit_standard_minutes(day_credit),
      day_credit_amount_half_minutes_value: day_credit_half_minutes(day_credit)
    }
  end

  def day_credit_amount_select_data
    password_manager_ignore_data.merge(action: "day-credit-amount#sync")
  end

  def day_credit_amount_input_data(target)
    password_manager_ignore_data.merge(day_credit_amount_target: target)
  end

  def password_manager_ignore_data
    { "1p-ignore": true, "op-ignore": true }
  end
end
