class CreateGraphProtocolEnvironments < ActiveRecord::Migration[7.0]
  def change
    create_table :graph_protocol_environments, id: :uuid do |t|
      t.string :name, unique: true, required: true
      t.string :gateway_url, required: true
      t.string :api_keys, array: true, default: [], required: true
      t.timestamps
    end
  end
end
