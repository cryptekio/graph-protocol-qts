class GraphProtocol::QuerySetImportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(query_set_id:)
    begin
      query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)
      return if query_set.get_status == :ready

      query_set.set_status :importing
      GraphProtocol::Util::QuerySet::Importer.execute!(query_set)
      query_set.set_status :ready
    rescue SignalException => e
      query_set.set_status :failed
    rescue GraphProtocol::Util::QuerySet::ImporterError => e
      query_set.set_status :failed
    end
  end
end
