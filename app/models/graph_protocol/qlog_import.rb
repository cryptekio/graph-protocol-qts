class GraphProtocol::QlogImport < ApplicationRecord
  belongs_to :query_set
  has_many :qlog_import_chunks

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
      status = :importing
      GraphProtocol::QuerySetMasterImportJob.perform_later(id: id)
    end
end
