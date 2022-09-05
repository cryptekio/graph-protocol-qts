class CreateGraphProtocolQuerySets < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_query_sets do |t|
      #t.has_many :queries, dependent: :destroy
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
