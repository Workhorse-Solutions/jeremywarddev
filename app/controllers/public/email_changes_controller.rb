class Public::EmailChangesController < Public::BaseController
  def show
    user = User.find_by_token_for(:email_change, params[:token])

    unless user
      flash[:alert] = t("public.email_changes.show.invalid_token")
      redirect_to login_path
      return
    end

    old_email = user.email
    user.confirm_email_change!
    UserMailer.email_changed_notification(user, old_email).deliver_later

    flash[:notice] = t("public.email_changes.show.success")
    redirect_to login_path
  end
end
