class GraphProtocol::Test < ApplicationRecord
  belongs_to :query_set
  belongs_to :environment
  has_many :instances, dependent: :destroy
  validates :query_set_id, :chunk_size, :sleep_enabled, :loop_queries, presence: true
  before_validation :set_default_values, on: :create

  def json_print
    env_name = self.environment.nil? ? "null" : self.environment.name
    query_set_name = self.query_set.name
    self.slice(:id,
               :subgraphs,
               :query_limit,
               :chunk_size,
               :speed_factor,
               :loop_queries,
               :sleep_enabled).merge({:environment => env_name}).merge({:query_set => query_set_name}).merge({:instances => instance_preview})
  end

  def instance_preview
    result = []
    self.instances.each do |instance|
      result << { instance.id => instance.get_status }
    end
    result
  end

  def loop?
    self.loop_queries
  end

  def set_default_values
    self.subgraphs = [] if self.subgraphs.nil?
    self.chunk_size = 100 if self.chunk_size.blank?
    self.sleep_enabled = true if self.sleep_enabled.nil?
    self.speed_factor = 1.0 if self.speed_factor.nil?
    self.loop_queries = false if self.loop_queries.nil?
  end

end
