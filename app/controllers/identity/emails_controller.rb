class Identity::EmailsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to_root
    else
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.permit(:email, :password_challenge).with_defaults(password_challenge: "")
    end

    def redirect_to_root
      if @user.email_previously_changed?
        redirect_to root_path, notice: "Your email has been changed"
      else
        redirect_to root_path
      end
    end
end
