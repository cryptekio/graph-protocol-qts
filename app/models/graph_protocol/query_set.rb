class GraphProtocol::QuerySet < ApplicationRecord
  has_many :queries, dependent: :destroy
  has_many :qlog_imports

  QUERY_SET_STATUS = [:created,:importing,:ready,:failed]

  def status
    QUERY_SET_STATUS[read_attribute(:status)]
  end

  def status=(new_status)
    write_attribute(:status,QUERY_SET_STATUS.find_index(new_status))
  end

end
