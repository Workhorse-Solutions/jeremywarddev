# Syncs new subscribers to ConvertKit or Mailchimp.
# Configure via CONVERTKIT_API_KEY or MAILCHIMP_API_KEY env vars.
class SyncSubscriberJob < ApplicationJob
  queue_as :default

  def perform(subscriber_id)
    subscriber = Subscriber.find(subscriber_id)

    if ENV["CONVERTKIT_API_KEY"].present?
      sync_to_convertkit(subscriber)
    elsif ENV["MAILCHIMP_API_KEY"].present?
      sync_to_mailchimp(subscriber)
    else
      Rails.logger.info "No email service configured. Subscriber #{subscriber.email} saved locally only."
    end
  end

  private

  def sync_to_convertkit(subscriber)
    # ConvertKit API v3
    uri = URI("https://api.convertkit.com/v3/forms/#{ENV['CONVERTKIT_FORM_ID']}/subscribe")
    payload = {
      api_key: ENV["CONVERTKIT_API_KEY"],
      email: subscriber.email,
      first_name: subscriber.name
    }

    response = Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")

    if response.code.to_i == 200
      Rails.logger.info "Synced #{subscriber.email} to ConvertKit"
    else
      Rails.logger.error "ConvertKit sync failed for #{subscriber.email}: #{response.body}"
    end
  end

  def sync_to_mailchimp(subscriber)
    # Mailchimp API v3 — requires MAILCHIMP_API_KEY and MAILCHIMP_LIST_ID
    api_key = ENV["MAILCHIMP_API_KEY"]
    list_id = ENV["MAILCHIMP_LIST_ID"]
    dc = api_key.split("-").last # Data center from API key

    uri = URI("https://#{dc}.api.mailchimp.com/3.0/lists/#{list_id}/members")
    payload = {
      email_address: subscriber.email,
      status: "subscribed",
      merge_fields: { FNAME: subscriber.name.to_s }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("anystring", api_key)
    request["Content-Type"] = "application/json"
    request.body = payload.to_json

    response = http.request(request)

    if response.code.to_i.between?(200, 299)
      Rails.logger.info "Synced #{subscriber.email} to Mailchimp"
    else
      Rails.logger.error "Mailchimp sync failed for #{subscriber.email}: #{response.body}"
    end
  end
end
