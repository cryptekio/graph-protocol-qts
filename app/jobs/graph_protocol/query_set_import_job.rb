class GraphProtocol::QuerySetImportJob < ApplicationJob
  queue_as :default

  def perform(args = {})
    GraphProtocol::Util::QuerySet::Importer.execute!(query_set_id: args[:query_set_id])
  end

end
