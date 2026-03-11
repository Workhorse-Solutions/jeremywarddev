class Public::InvitationsController < Public::BaseController
  before_action :find_invitation

  def show
    if @invitation.nil?
      @error = I18n.t("public.invitations.errors.invalid_or_expired")
    elsif @invitation.accepted?
      @error = I18n.t("public.invitations.errors.already_used")
    elsif logged_in? && current_user.email.downcase != @invitation.email.downcase
      @error = I18n.t("public.invitations.errors.wrong_email")
    end
  end

  def accept
    if @invitation.nil?
      redirect_to root_path, alert: I18n.t("public.invitations.errors.invalid_or_expired")
      return
    end

    if @invitation.accepted?
      redirect_to root_path, alert: I18n.t("public.invitations.errors.already_used")
      return
    end

    unless logged_in?
      session[:pending_invitation_token] = params[:token]
      redirect_to login_path, notice: I18n.t("public.invitations.login_to_accept")
      return
    end

    if current_user.email.downcase != @invitation.email.downcase
      redirect_to invitation_path(token: params[:token]), alert: I18n.t("public.invitations.errors.wrong_email")
      return
    end

    @invitation.accept!(current_user)
    redirect_to dashboard_path, notice: I18n.t("public.invitations.accepted")
  end

  private

  def find_invitation
    @invitation = Invitation.find_by_token_for(:acceptance, params[:token])
  end

  def logged_in?
    current_user.present?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
