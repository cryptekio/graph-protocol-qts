class AddSubgraphsIndexToGraphProtocolQueries < ActiveRecord::Migration[7.0]
  def change
    add_index :graph_protocol_queries, [:query_set_id, :subgraph, :offset], order: {query_set_id: :asc, offset: :asc}, name: "sort_by_subgraph"
  end
end
