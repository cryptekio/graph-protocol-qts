class CreateGraphProtocolTestInstances < ActiveRecord::Migration[7.0]
  def change

    create_table :graph_protocol_tests, id: :uuid do |t|
      t.belongs_to :query_set, type: :uuid
      t.integer :query_limit, default: :null
      t.integer :workers, default: 50
      t.string :subgraphs, array: true

      t.timestamps
    end

    create_table :graph_protocol_test_instances, id: :uuid do |t|
      t.belongs_to :test, type: :uuid
      t.integer :status, default: 0
      t.timestamp :started_at
      t.timestamp :finished_at

      t.timestamps
    end
  end
end
