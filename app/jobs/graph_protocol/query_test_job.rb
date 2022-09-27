class GraphProtocol::QueryTestJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(args = {})
    manager = GraphProtocol::AsyncRequestManager.new
    manager.fire_requests!(args)
  end
end
