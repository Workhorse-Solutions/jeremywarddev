class Public::EmailVerificationsController < Public::BaseController
  def show
    token = params[:token]

    # No token — render an informational "request new link" page
    unless token.present?
      render :show
      return
    end

    user = User.find_by_token_for(:email_verification, token)

    unless user
      flash[:alert] = t("public.email_verifications.show.invalid_token")
      redirect_to verify_email_path
      return
    end

    user.mark_email_verified!

    # Sign the user in if they're not already
    unless session[:user_id] == user.id
      reset_session
      session[:user_id] = user.id
      session[:session_token] = user.session_token
    end

    flash[:notice] = t("public.email_verifications.show.success")
    redirect_to dashboard_path
  end

  def resend
    user = User.find_by(email: params[:email]&.downcase&.strip)
    if user && !user.email_verified?
      UserMailer.verification_email(user).deliver_later
    end
    # Always show neutral flash to prevent enumeration
    flash[:notice] = t("public.email_verifications.resend.notice")
    redirect_to verify_email_path
  end
end
