class Admin::UsersController < Admin::BaseController
  include Pagy::Method

  def index
    users = User.order(created_at: :desc)
    users = users.where("first_name LIKE :q OR last_name LIKE :q OR email LIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @pagy, @users = pagy(:offset, users, limit: 25)
  end

  def verify_email
    user = User.find(params[:id])

    if user.email_verified?
      redirect_to admin_users_path, notice: t(".already_verified")
    else
      user.mark_email_verified!
      Rails.logger.info("[ADMIN] #{Current.user.email} verified email for user #{user.id} (#{user.email})")
      redirect_to admin_users_path, notice: t(".success")
    end
  end

  def force_password_reset
    user = User.find(params[:id])
    user.generate_session_token!
    UserMailer.password_reset_email(user).deliver_later
    Rails.logger.info("[ADMIN] #{Current.user.email} forced password reset for user #{user.id} (#{user.email})")
    redirect_to admin_users_path, notice: t(".success")
  end

  def impersonate
    if session[:impersonator_id].present?
      redirect_to admin_users_path, alert: t("admin.impersonations.start.already_impersonating")
      return
    end

    user = User.find(params[:id])
    Rails.logger.info("[ADMIN] #{Current.user.email} started impersonating user #{user.id} (#{user.email})")
    session[:impersonator_id] = Current.user.id
    session[:user_id] = user.id
    session[:session_token] = user.session_token
    redirect_to dashboard_path, notice: t("admin.impersonations.start.success", name: user.full_name)
  end
end
