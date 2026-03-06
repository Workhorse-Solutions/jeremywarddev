class Authenticated::BaseController < ApplicationController
  layout "authenticated"

  before_action :authenticate!

  private

  def authenticate!
    Current.user = User.find_by(id: session[:user_id])

    unless Current.user
      redirect_to login_path, status: :see_other
      return
    end

    # Invalidate sessions rotated by password reset or change
    if session[:session_token] != Current.user.session_token
      reset_session
      redirect_to login_path, status: :see_other
      return
    end

    Current.account = current_account

    unless Current.account
      Rails.logger.error("Authenticated user #{Current.user.id} has no accounts")
      reset_session
      redirect_to login_path, status: :see_other
    end
  end

  def current_account
    if session[:account_id]
      Current.user.accounts.find_by(id: session[:account_id])
    end || Current.user.accounts.order("account_users.created_at").first
  end

  def current_account_user
    @current_account_user ||= Current.account.account_users.find_by(user: Current.user)
  end
  helper_method :current_account_user
end
