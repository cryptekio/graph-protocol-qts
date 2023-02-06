class GraphProtocol::Environment < ApplicationRecord
  has_many :tests
  validates :gateway_url, :api_keys, :name, presence: true
  validates :name, :uniqueness => true

  def api_key
    self.api_keys.sample
  end

  def json_print
    self.slice(:id,
               :name,
               :api_keys,
               :gateway_url)
  end

end
