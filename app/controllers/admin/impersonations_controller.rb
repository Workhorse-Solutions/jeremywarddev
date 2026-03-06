class Admin::ImpersonationsController < Authenticated::BaseController
  def destroy
    impersonator = User.find_by(id: session[:impersonator_id])

    unless impersonator&.system_admin?
      head :not_found
      return
    end

    Rails.logger.info("[ADMIN] #{impersonator.email} stopped impersonating user #{Current.user.id} (#{Current.user.email})")
    session.delete(:impersonator_id)
    session[:user_id] = impersonator.id
    session[:session_token] = impersonator.session_token
    redirect_to admin_users_path, notice: t("admin.impersonations.stop.success")
  end
end
