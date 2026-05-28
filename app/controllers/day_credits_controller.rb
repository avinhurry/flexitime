class DayCreditsController < ApplicationController
  def new
    @day_credit = current_user.day_credits.build(
      credit_date: default_credit_date,
      credit_type: "bank_holiday",
      credited_minutes: DayCredit.default_credited_minutes_for(current_user)
    )
  end

  def create
    @day_credit = current_user.day_credits.build(day_credit_params)

    if @day_credit.save
      redirect_to week_path_for(@day_credit), notice: "Day credit recorded successfully."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @day_credit = current_user.day_credits.find(params[:id])
  end

  def update
    @day_credit = current_user.day_credits.find(params[:id])

    if @day_credit.update(day_credit_params)
      redirect_to week_path_for(@day_credit), notice: "Day credit updated successfully."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @day_credit = current_user.day_credits.find(params[:id])
    week_start = TimeEntry.work_week_range(@day_credit.credit_date).begin.to_date
    @day_credit.destroy

    redirect_to time_entries_path(week_start: week_start), notice: "Day credit deleted successfully."
  end

  private

  def day_credit_params
    permitted = params.require(:day_credit).permit(
      :credit_date,
      :credit_type,
      :credited_hours_part,
      :credited_minutes_part,
      :note
    )

    apply_amount_preset(permitted)
  end

  def current_user
    @current_user ||= Current.user
  end

  def default_credit_date
    return Date.current if params[:date].blank?

    Date.parse(params[:date])
  rescue Date::Error
    Date.current
  end

  def apply_amount_preset(permitted)
    case params[:amount_preset]
    when "standard"
      assign_credited_minutes(permitted, DayCredit.default_credited_minutes_for(current_user))
    when "half"
      assign_credited_minutes(permitted, (DayCredit.default_credited_minutes_for(current_user) / 2.0).round)
    end

    permitted
  end

  def assign_credited_minutes(permitted, total_minutes)
    permitted[:credited_hours_part] = total_minutes / 60
    permitted[:credited_minutes_part] = total_minutes % 60
  end

  def week_path_for(day_credit)
    week_start = TimeEntry.work_week_range(day_credit.credit_date).begin.to_date
    time_entries_path(week_start: week_start)
  end
end
