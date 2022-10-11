class CreateGraphProtocolQlogImports < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_qlog_imports, id: :uuid do |t|
      t.belongs_to :query_set, type: :uuid
      t.integer :sequence
      t.integer :status
      t.text :input
      t.text :remain
      t.timestamp :started_at
      t.timestamp :finished_at
      t.timestamps

      #t.index [:graph_protocol_query_set, :sequence], order: {sequence: :asc}, name: "sort_by_sequence"
    end
  end
end
