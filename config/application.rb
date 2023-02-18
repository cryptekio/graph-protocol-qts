require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module GraphProtocolQts
  class Application < Rails::Application
    config.eager_load_paths << Rails.root.join('lib')
    config.load_defaults 7.0
    config.active_job.queue_adapter = :sidekiq
    config.log_level = :warn
    config.log_tags = [:subdomain, :uuid]
    config.logger    = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))

    config.api_only = true
  end
end
