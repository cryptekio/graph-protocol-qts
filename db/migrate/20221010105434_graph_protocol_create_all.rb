class GraphProtocolCreateAll < ActiveRecord::Migration[7.0]
  def change

    enable_extension 'pgcrypto'

    create_table :graph_protocol_query_sets, id: :uuid do |t|
      t.string :name
      t.string :description

      t.timestamps
    end

    create_table :graph_protocol_queries, id: :uuid do |t|
      t.belongs_to :query_set, type: :uuid
      t.string :query_id
      t.string :subgraph
      t.string :variables
      t.text :query
      t.float :offset
      t.float :timestamp

      t.index [:query_set_id, :offset], order: {query_set_id: :asc, offset: :asc}
      t.index [:query_set_id, :subgraph, :offset], order: {query_set_id: :asc, offset: :asc}, name: "sort_by_subgraph"
      t.timestamps
    end

  end
end
