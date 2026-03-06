class UserMailerPreview < ActionMailer::Preview
  def verification_email
    UserMailer.verification_email(User.first)
  end

  def password_reset_email
    UserMailer.password_reset_email(User.first)
  end

  def email_change_confirmation
    user = User.first
    user.unconfirmed_email ||= "new@example.com"
    UserMailer.email_change_confirmation(user)
  end

  def email_changed_notification
    UserMailer.email_changed_notification(User.first, "old@example.com")
  end
end
