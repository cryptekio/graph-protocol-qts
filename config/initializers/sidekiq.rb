Sidekiq.configure_server do |config|
  config.logger.level = Rails.logger.level
  config.redis = { url: Rails.application.secrets.redis_url, network_timeout: 30, pool_timeout: 30, size: 1000 }
end
