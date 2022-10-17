class GraphProtocol::QuerySetMasterImportJob < ApplicationJob
  queue_as :default

  def perform(id:)
    import = GraphProtocol::QlogImport.find_by(id: id)
    import.object_size = GraphProtocol::Util::S3::ObjectProcessor.get_object_size(key: import.query_set.file_path)
    import.status = :importing

    first_chunk = GraphProtocol::QlogImportChunk.create(qlog_import: import,
                                                        status: 0)

    first_chunk.import!

    #
    # Monitor chunk imports here
    #

  end
end
