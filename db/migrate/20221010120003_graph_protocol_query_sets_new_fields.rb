class GraphProtocolQuerySetsNewFields < ActiveRecord::Migration[7.0]
  def change
    add_column :graph_protocol_query_sets, :status, :integer, default: 0
    add_column :graph_protocol_query_sets, :import_type, :string, null: false
    add_column :graph_protocol_query_sets, :file_path, :string, null: false
    add_column :graph_protocol_query_sets, :query_set_type, :string, null: false
    add_column :graph_protocol_query_sets, :object_size, :bigint
  end
end
