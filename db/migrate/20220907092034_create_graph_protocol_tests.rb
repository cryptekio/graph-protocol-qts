class CreateGraphProtocolTests < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_tests do |t|
      t.string :uuid
      t.string :integer
      t.references :graph_protocol_query_set, null: false, foreign_key: true

      t.timestamps
    end
  end
end
