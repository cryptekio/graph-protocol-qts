class GraphProtocol::QuerySetSequenceImportJob < ApplicationJob
  queue_as :default

  def perform(id:)
    GraphProtocol::Util::QuerySet::Import::Sequence.execute!(sequence_id: id)
  end
end
