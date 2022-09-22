class GraphProtocol::Query < ApplicationRecord
  belongs_to :query_set

  def self.subgraphs(subgraphs = [])
    query = "" 
    subgraphs.each_with_index do |subgraph,index|
      query = query + "subgraph = \'#{subgraph}\'"
      query = query + " or " unless subgraphs.count == index+1
    end

    where(query)
  end

  def self.sort_by_offset
    order(:offset)
  end

end
