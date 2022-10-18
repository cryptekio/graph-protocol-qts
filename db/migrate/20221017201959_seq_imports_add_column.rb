class SeqImportsAddColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :graph_protocol_query_set_sequence_imports, :prefix, :text
  end
end
