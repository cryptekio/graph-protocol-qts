class GraphProtocol::QuerySet < ApplicationRecord
  has_many :queries, dependent: :destroy
  after_commit :import_dataset, on: :create
  validates :name, :status, :file_path, :import_type, :query_set_type, presence: true
  before_validation :set_default_values, on: :create

  QUERY_SET_STATUS = [:created,:importing,:ready,:failed]

  def get_status
    QUERY_SET_STATUS[read_attribute(:status)]
  end

  def set_status(new_status)
    update_attribute(:status,QUERY_SET_STATUS.find_index(new_status))
  end

  def import_dataset
    GraphProtocol::QuerySetImportJob.perform_later(query_set_id: self.id)
  end

  def set_default_values
    self.set_status = :created if self.status.blank?
    self.import_type = "s3" if self.import_type.blank?
    self.query_set_type = "qlog" if self.query_set_type.blank?
  end
end
