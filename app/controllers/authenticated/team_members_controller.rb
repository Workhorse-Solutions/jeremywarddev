class Authenticated::TeamMembersController < Authenticated::BaseController
  before_action :require_manager!
  before_action :find_account_user

  def destroy
    if current_account_user.role == "admin" && @account_user.role == "owner"
      redirect_to team_path, alert: I18n.t("authenticated.team_members.destroy.cannot_remove_owner"), status: :see_other
      return
    end

    if @account_user.last_owner?
      redirect_to team_path, alert: I18n.t("authenticated.team_members.destroy.last_owner_error"), status: :see_other
      return
    end

    name = @account_user.user.full_name
    account_name = Current.account.name
    @account_user.destroy!

    redirect_to team_path, notice: I18n.t("authenticated.team_members.destroy.notice", name: name, account_name: account_name), status: :see_other
  end

  private

  def find_account_user
    @account_user = Current.account.account_users.find(params[:id])
  end

  def require_manager!
    unless current_account_user&.can_manage_members?
      redirect_to team_path, alert: I18n.t("authenticated.invitations.unauthorized"), status: :see_other
    end
  end
end
