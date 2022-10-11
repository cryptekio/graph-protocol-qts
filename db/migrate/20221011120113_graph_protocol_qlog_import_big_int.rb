class GraphProtocolQlogImportBigInt < ActiveRecord::Migration[7.0]
  def change
    change_column :graph_protocol_qlog_imports, :range_start, :bigint
    change_column :graph_protocol_qlog_imports, :range_end, :bigint
  end
end
