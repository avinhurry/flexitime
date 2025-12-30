class WorkSchedulesController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(work_schedule_params)
      redirect_to account_path, notice: "Work schedule updated"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def work_schedule_params
      params.require(:user).permit(:contracted_hours, :working_days_per_week)
    end
end
