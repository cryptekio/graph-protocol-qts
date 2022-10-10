class GraphProtocol::QuerySet < ApplicationRecord
  has_many :queries, dependent: :destroy
end
