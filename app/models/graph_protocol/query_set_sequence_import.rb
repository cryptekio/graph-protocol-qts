class GraphProtocol::QuerySetSequenceImport < ApplicationRecord
  belongs_to :query_set

  IMPORT_STATUS = [:created,:importing,:ready,:failed]

  def get_status
    IMPORT_STATUS[read_attribute(:status)]
  end

  def set_status=(new_status)
    update_attribute(:status,IMPORT_STATUS.find_index(new_status))
  end

  def set_suffix=(line)
    update_attribute(:suffix,line)
  end

  def set_prefix=(line)
    update_attribute(:prefix,line)
  end

  def get_suffix_query
    unless suffix.nil?
      next_seq = GraphProtocol::QuerySetSequenceImport.find_by(query_set: query_set,
                                                             index: index+1)
      next_seq_prefix = next_seq.prefix
      suffix + next_seq_prefix
    end
  end

  def import!
    GraphProtocol::QuerySetSequenceImportJob.perform_later(id: id)
  end

end
