class GraphProtocol::QuerySetMasterImportJob < ApplicationJob
  queue_as :default

  def perform(id:)
    master = GraphProtocol::Util::QuerySet::Import::Master.new(query_set_id: id)
    master.execute!
  end

end
