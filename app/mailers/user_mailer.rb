class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verification_url = verify_email_url(token: user.generate_token_for(:email_verification))
    mail(to: @user.email, subject: "Please verify your email address")
  end

  def password_reset_email(user)
    @user = user
    @reset_url = edit_password_reset_url(token: user.password_reset_token)
    mail(to: @user.email, subject: "Reset your password")
  end

  def email_change_confirmation(user)
    @user = user
    @confirm_url = confirm_email_change_url(token: user.generate_token_for(:email_change))
    mail(to: @user.unconfirmed_email, subject: "Confirm your new email address")
  end

  def email_changed_notification(user, old_email)
    @user = user
    mail(to: old_email, subject: "Your email address has been changed")
  end
end
