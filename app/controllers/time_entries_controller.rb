class TimeEntriesController < ApplicationController
  def index
    @time_entries = current_user.time_entries.order(clock_in: :asc)
    @week_start = params[:week_start] ? Date.parse(params[:week_start]) : Date.today
    @work_week_start = @week_start.beginning_of_week(:monday)
    @work_week_end = @work_week_start + 4.days
    total_hours_decimal = TimeEntry.total_hours_for_week(@week_start)
    @total_hours = TimeEntry.format_decimal_hours_to_hours_minutes(total_hours_decimal)
    @hours_difference = TimeEntry.hours_difference_for_week(@week_start)
  end

  def new
    @time_entry = current_user.time_entries.build
  end
  def create
    @time_entry = current_user.time_entries.build(time_entry_params)

    if @time_entry.save
      redirect_to time_entries_path, notice: "Time entry recorded successfully."
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
      redirect_to time_entries_path, notice: "Time entry updated successfully."
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
