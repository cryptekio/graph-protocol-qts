class GraphProtocol::DeleteQuerySetJob < ApplicationJob
  queue_as :default

  def perform(query_set_id:)
    query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)
    query_set.destroy unless query_set.nil?
  end
end
