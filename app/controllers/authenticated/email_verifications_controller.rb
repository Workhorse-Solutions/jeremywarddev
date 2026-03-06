class Authenticated::EmailVerificationsController < Authenticated::BaseController
  def resend
    UserMailer.verification_email(Current.user).deliver_later unless Current.user.email_verified?

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to dashboard_path, notice: t("authenticated.email_verifications.resend.notice") }
    end
  end
end
