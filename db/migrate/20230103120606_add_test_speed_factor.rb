class AddTestSpeedFactor < ActiveRecord::Migration[7.0]
  def change
    add_column :graph_protocol_tests, :speed_factor, :float, default: 1.0
  end
end
