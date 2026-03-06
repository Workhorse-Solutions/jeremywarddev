class Authenticated::EmailChangesController < Authenticated::BaseController
  def edit
    @form = EmailChangeForm.new
  end

  def update
    @form = EmailChangeForm.new(form_params)
    @form.user = Current.user

    if @form.save
      respond_to do |format|
        format.turbo_stream
        format.html do
          flash[:notice] = t("authenticated.email_changes.update.notice")
          redirect_to edit_settings_profile_path
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private

  def form_params
    params.require(:email_change).permit(:new_email, :current_password)
  end
end
