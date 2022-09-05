class GraphProtocol::QueryFireworksJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(*args)
    query_set = GraphProtocol::QuerySet.find_by(:id => args[:query_set_id])
  end

end
