class AddUniqueIndexToGraphProtocolTests < ActiveRecord::Migration[7.0]
  def change
    add_index :graph_protocol_tests, :uuid, unique: true
  end
end
