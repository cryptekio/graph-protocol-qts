class AddUuidAndIndexToGraphProtocolQuerySet < ActiveRecord::Migration[7.0]
  def change
    add_column :graph_protocol_query_sets, :uuid, :string
    add_index :graph_protocol_query_sets, :uuid, unique: true
  end
end
