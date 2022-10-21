class GraphProtocol::QuerySetImportJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2, dead: false 

  def perform(query_set_id:)
    begin
      query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)
      query_set.set_status :importing
      GraphProtocol::Util::QuerySet::Importer.execute!(query_set)
      query_set.set_status :ready
    rescue GraphProtocol::Util::QuerySet::ImporterError => e
      set_to_failed(query_set.id)
      return 
    end
  end

  sidekiq_retries_exhausted do |msg, ex|
    set_to_failed(msg['args']['query_set_id'])
  end

  def set_to_failed(query_set_id)
    query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)
    query_set.set_status :failed unless query_set.nil?
  end

end
