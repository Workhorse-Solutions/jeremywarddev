# RailsFoundry central configuration.
#
# When cloning this template for a new app, set APP_IDENTIFIER (and optionally
# APP_NAME) in your environment / .env file. Every collision-sensitive config
# (session cookie key, database names, etc.) derives from these two values so
# that multiple RailsFoundry-based apps can coexist on the same machine without
# stomping on each other.
#
# Defaults (safe to leave for the template itself):
#   APP_IDENTIFIER=railsfoundry
#   APP_NAME=RailsFoundry
module RailsFoundry
  class Configuration
    attr_reader :app_identifier, :app_name

    def initialize
      @app_identifier = ENV.fetch("APP_IDENTIFIER", "railsfoundry")
      @app_name       = ENV.fetch("APP_NAME", "RailsFoundry")
    end
  end

  class << self
    def config
      @config ||= Configuration.new
    end
  end
end
