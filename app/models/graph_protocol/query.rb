class GraphProtocol::Query < ApplicationRecord
  belongs_to :query_set

  def self.subgraphs(subgraphs = [])
    if subgraphs
      query = "" 
      subgraphs.each_with_index do |subgraph,index|
        query = query + "subgraph = \'#{subgraph}\'"
        query = query + " or " unless subgraphs.count == index+1
      end
      where(query)
    end
  end

  def self.sort_by_delay
    order(:offset)
  end

  def self.set_offset(start_offset)
    start_offset ? offset(start_offset) : all 
  end

  def self.set_limit(max_limit)
    max_limit ? limit(max_limit) : all
  end

end
