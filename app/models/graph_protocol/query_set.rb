class GraphProtocol::QuerySet < ApplicationRecord
  has_many :queries, dependent: :destroy
  has_many :query_set_sequence_imports, dependent: :destroy

  QUERY_SET_STATUS = [:created,:importing,:ready,:failed]

  def get_status
    QUERY_SET_STATUS[read_attribute(:status)]
  end

  def set_status=(new_status)
    update_attribute(:status,QUERY_SET_STATUS.find_index(new_status))
  end

  def set_object_size=(size)
    update_attribute(:object_size,size)
  end

  def import!
    GraphProtocol::QuerySetMasterImportJob.perform_later(id: id)
  end

  def create_sequence(index:, range_start:, range_end:)
    query_set_sequence_imports.create(index: index,
                                      status: 0,
                                      range_start: range_start,
                                      range_end: range_end)
  end



end
