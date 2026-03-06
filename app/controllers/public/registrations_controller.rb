class Public::RegistrationsController < Public::BaseController
  def new
    @registration = RegistrationForm.new
  end

  def create
    @registration = RegistrationForm.new(signup_params)

    if @registration.save
      pending_token = session[:pending_invitation_token]
      reset_session
      session[:user_id] = @registration.user.id
      session[:session_token] = @registration.user.session_token
      UserMailer.verification_email(@registration.user).deliver_later
      redirect_to after_signup_path(pending_token)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def signup_params
    params.require(:registration).permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end

  def after_signup_path(pending_token)
    if pending_token.present?
      invitation_path(token: pending_token)
    else
      dashboard_path
    end
  end
end
