class GraphProtocol::Test < ApplicationRecord
  belongs_to :query_set
  has_many :instances, dependent: :destroy
  validates :query_set_id, :chunk_size, :sleep_enabled, presence: true
  before_validation :set_default_values, on: :create

  def json_print
    self.slice(:id,
               :query_set_id,
               :subgraphs,
               :query_limit,
               :chunk_size,
               :speed_factor,
               :sleep_enabled).merge({:instances => instance_preview})
  end

  def instance_preview
    result = []
    self.instances.each do |instance|
      result << { instance.id => instance.get_status }
    end
    result
  end

  def set_default_values
    self.subgraphs = [] if self.subgraphs.nil?
    self.chunk_size = 1000 if self.chunk_size.blank?
    self.sleep_enabled = true if self.sleep_enabled.nil?
    self.speed_factor = 1.0 if self.speed_factor.nil?
  end

end
