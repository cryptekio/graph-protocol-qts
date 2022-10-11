class GraphProtocolQlogImportAddRanges < ActiveRecord::Migration[7.0]
  def change
    add_column :graph_protocol_qlog_imports, :range_start, :integer
    add_column :graph_protocol_qlog_imports, :range_end, :integer
  end
end
