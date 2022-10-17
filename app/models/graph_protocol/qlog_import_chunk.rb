class GraphProtocol::QlogImportChunk < ApplicationRecord
  belongs_to :qlog_import

  IMPORT_STATUS = [:created,:importing,:ready,:failed]

  def status
    IMPORT_STATUS[read_attribute(:status)]
  end

  def status=(new_status)
    write_attribute(:status,IMPORT_STATUS.find_index(new_status))
    query_set.status = IMPORT_STATUS.find_index(new_status)
    save
  end

  def import!
    GraphProtocol::QuerySetChunkImportJob.perform_later(id: id)
  end

end
