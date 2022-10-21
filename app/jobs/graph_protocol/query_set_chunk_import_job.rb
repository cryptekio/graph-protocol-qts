class GraphProtocol::QuerySetChunkImportJob < ApplicationJob
  queue_as :default

  def perform(query_set_id:, range_start:, object_size:, chunk_size:)
    query_set = GraphProtocol::QuerySet.find_by(:id => query_set_id)

    GraphProtocol::Util::QuerySet::Importer.import_qlog_chunk_from_s3(
      query_set: query_set,
      range_start: range_start,
      object_size: object_size,
      chunk_size: chunk_size
    )

  end

end
