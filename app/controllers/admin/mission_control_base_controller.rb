class Admin::MissionControlBaseController < Admin::BaseController
  private

  def authenticate!
    Current.user = User.find_by(id: session[:user_id])

    unless Current.user
      head :not_found
      return
    end

    if session[:session_token] != Current.user.session_token
      reset_session
      head :not_found
    end
  end
end
