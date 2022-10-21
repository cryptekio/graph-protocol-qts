class GraphProtocol::Test < ApplicationRecord
  belongs_to :query_set
  has_many :instances, dependent: :destroy
  validates :query_set_id, :chunk_size, :sleep_enabled, presence: true
  before_validation :set_default_values, on: :create

  def json_print
    self.slice(:query_set_id,
               :subgraphs,
               :chunk_size,
               :sleep_enabled).merge({:instances => instance_ids})
  end

  def instance_ids
    result = []
    self.instances.each do |instance|
      result << instance.id
    end
    result
  end

  def set_default_values
    self.subgraphs = [] if self.subgraphs.nil?
    self.chunk_size = 1000 if self.chunksize.blank?
    self.sleep_enabled = true if self.sleep_enabled.nil?
  end

end
