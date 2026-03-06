class Public::PasswordResetsController < Public::BaseController
  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase&.strip)
    if user
      UserMailer.password_reset_email(user).deliver_later
    end
    # Always show neutral flash to prevent email enumeration
    flash[:notice] = t("public.password_resets.create.notice")
    redirect_to login_path
  end

  def edit
    @token = params[:token]
    unless User.find_by_password_reset_token(@token)
      flash[:alert] = t("public.password_resets.edit.invalid_token")
      redirect_to new_password_reset_path
    end
  end

  def update
    user = User.find_by_password_reset_token(params[:token])

    unless user
      flash[:alert] = t("public.password_resets.edit.invalid_token")
      redirect_to new_password_reset_path
      return
    end

    if user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      user.generate_session_token!
      flash[:notice] = t("public.password_resets.update.notice")
      redirect_to login_path
    else
      @token = params[:token]
      flash.now[:alert] = user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end
end
