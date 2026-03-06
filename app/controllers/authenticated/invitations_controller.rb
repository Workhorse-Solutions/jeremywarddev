class Authenticated::InvitationsController < Authenticated::BaseController
  before_action :require_manager!

  def new
    @invitation_form = InvitationForm.new(account: Current.account, invited_by: Current.user)
  end

  def create
    @invitation_form = InvitationForm.new(
      account: Current.account,
      invited_by: Current.user,
      email: invitation_params[:email]
    )

    if @invitation_form.save
      @pending_invitations = Current.account.invitations.pending
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to team_path, notice: I18n.t("authenticated.invitations.create.notice", email: @invitation_form.email) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def invitation_params
    params.require(:invitation_form).permit(:email)
  end

  def require_manager!
    unless current_account_user&.can_manage_members?
      redirect_to team_path, alert: I18n.t("authenticated.invitations.unauthorized"), status: :see_other
    end
  end
end
