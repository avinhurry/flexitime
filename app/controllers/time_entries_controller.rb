class TimeEntriesController < ApplicationController
  def index
    @time_entries = TimeEntry.all.order(created_at: :desc)
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

  private

  def time_entry_params
    params.require(:time_entry).permit(:clock_in, :clock_out)
  end
end
