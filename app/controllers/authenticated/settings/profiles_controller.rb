class Authenticated::Settings::ProfilesController < Authenticated::BaseController
  def edit
    @personal_details_form = Settings::PersonalDetailsForm.new(
      first_name: Current.user.first_name,
      last_name: Current.user.last_name
    )
    @personal_details_form.user = Current.user

    @password_form = Settings::PasswordForm.new
    @password_form.user = Current.user
  end

  def update
    @personal_details_form = Settings::PersonalDetailsForm.new(personal_details_params)
    @personal_details_form.user = Current.user

    if @personal_details_form.save
      flash[:notice] = t("authenticated.settings.profiles.update.notice")
      redirect_to edit_settings_profile_path
    else
      @password_form = Settings::PasswordForm.new
      @password_form.user = Current.user
      render :edit, status: :unprocessable_entity
    end
  end

  def update_password
    @password_form = Settings::PasswordForm.new(password_params)
    @password_form.user = Current.user

    if @password_form.save
      session[:session_token] = Current.user.session_token
      flash[:notice] = t("authenticated.settings.profiles.update_password.notice")
      redirect_to edit_settings_profile_path
    else
      @personal_details_form = Settings::PersonalDetailsForm.new(
        first_name: Current.user.first_name,
        last_name: Current.user.last_name
      )
      @personal_details_form.user = Current.user
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def personal_details_params
    params.require(:settings_profile).permit(:first_name, :last_name)
  end

  def password_params
    params.require(:settings_password).permit(:current_password, :password, :password_confirmation)
  end
end
