class GraphProtocol::Test < ApplicationRecord
  belongs_to :query_set
  has_many :test_instances, dependent: :destroy

end
