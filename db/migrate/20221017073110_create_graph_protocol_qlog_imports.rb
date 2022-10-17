class CreateGraphProtocolQlogImports < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_qlog_imports, id: :uuid do |t|
      t.belongs_to :query_set
      t.integer :status
      t.timestamps
    end
  end
end
