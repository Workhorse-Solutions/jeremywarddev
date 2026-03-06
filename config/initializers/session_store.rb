# Derive the session cookie name from APP_IDENTIFIER so that multiple
# RailsFoundry-based apps running on the same domain (e.g. localhost) do not
# overwrite each other's sessions.
Rails.application.config.session_store(
  :cookie_store,
  key: "_#{RailsFoundry.config.app_identifier}_session"
)
