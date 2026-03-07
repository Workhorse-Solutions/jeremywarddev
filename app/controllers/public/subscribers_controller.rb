class Public::SubscribersController < Public::BaseController
  def create
    @subscriber = Subscriber.new(subscriber_params)

    respond_to do |format|
      if @subscriber.save
        SyncSubscriberJob.perform_later(@subscriber.id) if email_service_configured?

        format.turbo_stream { render turbo_stream: turbo_stream.replace("email-form", partial: "public/subscribers/success") }
        format.html { redirect_to root_path, notice: "You're in! Check your inbox." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("email-form", partial: "public/subscribers/form", locals: { subscriber: @subscriber }) }
        format.html { redirect_to root_path, alert: @subscriber.errors.full_messages.join(", ") }
      end
    end
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email, :name)
  end

  def email_service_configured?
    ENV["CONVERTKIT_API_KEY"].present? || ENV["MAILCHIMP_API_KEY"].present?
  end
end
