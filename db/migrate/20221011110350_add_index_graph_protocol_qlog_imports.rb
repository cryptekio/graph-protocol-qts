class AddIndexGraphProtocolQlogImports < ActiveRecord::Migration[7.0]
  def change
     add_index :graph_protocol_qlog_imports, [:query_set_id, :sequence], order: {sequence: :asc}, name: "sort_by_sequence"
  end
end
