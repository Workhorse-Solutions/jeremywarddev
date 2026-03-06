class Authenticated::Settings::AccountsController < Authenticated::BaseController
  before_action :require_owner_or_admin!

  def edit
    @form = Settings::AccountForm.new(name: Current.account.name, slug: Current.account.slug)
    @form.account = Current.account
  end

  def update
    @form = Settings::AccountForm.new(form_params)
    @form.account = Current.account

    if @form.save
      flash[:notice] = t("authenticated.settings.accounts.update.notice")
      redirect_to edit_settings_account_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def require_owner_or_admin!
    unless current_account_user&.role.in?(%w[owner admin])
      redirect_to dashboard_path, notice: t("authenticated.settings.accounts.unauthorized")
    end
  end

  def form_params
    params.require(:settings_account).permit(:name, :slug)
  end
end
