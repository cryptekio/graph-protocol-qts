class AddEnvToTests < ActiveRecord::Migration[7.0]
  def change
    change_table :graph_protocol_tests do |t|
      t.belongs_to :environment, type: :uuid 
    end
  end
end
