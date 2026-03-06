class InvitationMailer < ApplicationMailer
  def invite_email(invitation)
    @invitation = invitation
    @inviter = invitation.invited_by_user
    @account = invitation.account
    @acceptance_url = invitation_url(token: invitation.generate_token_for(:acceptance))

    mail(to: invitation.email, subject: I18n.t("invitation_mailer.invite_email.subject", account_name: @account.name))
  end
end
