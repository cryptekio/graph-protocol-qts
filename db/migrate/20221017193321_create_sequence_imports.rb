class CreateSequenceImports < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_query_set_sequence_imports, id: :uuid do |t|
      t.belongs_to :query_set, type: :uuid
      t.integer :status
      t.integer :index
      t.bigint :range_start
      t.bigint :range_end
      t.bigint :object_size

      t.text :suffix

      t.timestamps
    end
  end
end
