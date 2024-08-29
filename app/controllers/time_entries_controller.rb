class TimeEntriesController < ApplicationController
  def index
    @time_entries = TimeEntry.all.order(clock_in: :asc)
    @week_start = params[:week_start] ? Date.parse(params[:week_start]) : Date.today
    @total_hours = TimeEntry.total_hours_for_week(@week_start)
    @hours_difference = TimeEntry.hours_difference_for_week(@week_start)
  end

  def new
    @time_entry = TimeEntry.new
  end

  def create
    @time_entry = TimeEntry.new(time_entry_params)

    if @time_entry.save
      redirect_to time_entries_path, notice: 'Time entry recorded successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @time_entry = TimeEntry.find(params[:id])
  end

  def update
    @time_entry = TimeEntry.find(params[:id])

    if @time_entry.update(time_entry_params)
      redirect_to time_entries_path, notice: 'Time entry updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.destroy
    redirect_to time_entries_path, notice: 'Time entry deleted successfully.'
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(:clock_in, :clock_out, :lunch_duration)
  end
end
