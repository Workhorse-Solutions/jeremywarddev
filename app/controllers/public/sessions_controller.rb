class Public::SessionsController < Public::BaseController
  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase&.strip)
    if user&.authenticate(params[:password])
      pending_token = session[:pending_invitation_token]
      reset_session
      session[:user_id] = user.id
      session[:session_token] = user.session_token
      redirect_to after_login_path(pending_token)
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path
  end

  private

  def after_login_path(pending_token)
    if pending_token.present?
      invitation_path(token: pending_token)
    else
      dashboard_path
    end
  end
end
