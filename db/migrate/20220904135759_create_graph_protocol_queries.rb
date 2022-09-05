class CreateGraphProtocolQueries < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_queries do |t|
      t.belongs_to :query_set
      t.string :query_id
      t.string :subgraph
      t.string :variables
      t.text :query
      t.float :offset
      t.float :timestamp

      t.index [:query_set_id, :offset], order: {query_set_id: :asc, offset: :asc}
      t.timestamps
    end
  end
end
