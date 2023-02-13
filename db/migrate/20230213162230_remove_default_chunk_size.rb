class RemoveDefaultChunkSize < ActiveRecord::Migration[7.0]
  def change
    change_column_default :graph_protocol_tests, :chunk_size, nil
  end
end
