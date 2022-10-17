class GraphProtocol::QuerySetChunkImportJob < ApplicationJob
  queue_as :default

  def perform(id:)
    import = GraphProtocol::QlogImportChunk.find_by(id: id)
    import.status = :importing
    GraphProtocol::Util::QuerySet::Importer.import_qlog_chunk_from_s3(import: import)

  end

end
