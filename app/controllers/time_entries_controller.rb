class TimeEntriesController < ApplicationController
  def index
    @week_start = params[:week_start] ? Date.parse(params[:week_start]) : Date.today
    work_week_range = TimeEntry.work_week_range(@week_start)
    @work_week_start = work_week_range.begin
    @work_week_end = work_week_range.end
    @time_entries = current_user.time_entries
      .where(clock_in: work_week_range)
      .order(clock_in: :asc)
    total_hours_decimal = TimeEntry.total_hours_for_week(@week_start, current_user)
    @total_hours = TimeEntry.format_decimal_hours_to_hours_minutes(total_hours_decimal)
    required_minutes = WeekEntry.required_minutes_for(current_user, @work_week_start)
    required_hours_decimal = required_minutes / 60.0
    @required_hours = TimeEntry.format_decimal_hours_to_hours_minutes(required_hours_decimal)
    @hours_difference = total_hours_decimal - required_hours_decimal
  end

  def new
    @time_entry = current_user.time_entries.build
  end

  def create
    @time_entry = current_user.time_entries.build(time_entry_params)

    if @time_entry.save
      week_start = TimeEntry.work_week_range(@time_entry.clock_in).begin.to_date
      redirect_to time_entries_path(week_start: week_start), notice: "Time entry recorded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @time_entry = current_user.time_entries.find(params[:id])
  end

  def update
    @time_entry = current_user.time_entries.find(params[:id])

    if @time_entry.update(time_entry_params)
      week_start = TimeEntry.work_week_range(@time_entry.clock_in).begin.to_date
      redirect_to time_entries_path(week_start: week_start), notice: "Time entry updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_entry = current_user.time_entries.find(params[:id])
    @time_entry.destroy
    redirect_to time_entries_path, notice: "Time entry deleted successfully."
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(:clock_in, :clock_out, :lunch_in, :lunch_out)
  end

  def current_user
    @current_user ||= Current.user
  end
end
