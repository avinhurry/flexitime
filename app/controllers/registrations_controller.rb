class RegistrationsController < ApplicationController
  before_action :require_admin_for_signup, only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      send_email_verification
      redirect_to root_path, notice: "Welcome! You have signed up successfully"
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def require_admin_for_signup
      return if Current.user&.admin?

      redirect_to sign_in_path,
        alert: invite_only_message
    end

    def handle_unauthenticated
      redirect_to sign_in_path, alert: invite_only_message
    end

    def invite_only_message
      "Sign-ups are closed. This app is invite-only - contact me if you need access."
    end

    def user_params
      params.permit(:email, :password, :password_confirmation, :contracted_hours, :working_days_per_week)
    end

    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
