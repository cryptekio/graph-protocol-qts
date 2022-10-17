class CreateGraphProtocolQlogImportChunks < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_qlog_import_chunks, id: :uuid do |t|
      t.belongs_to :qlog_import
      t.integer :status
      t.integer :sequence
      t.bigint :range_start
      t.bigint :range_end
      t.timestamps
    end
  end
end
