class AddTestInstanceAttrs < ActiveRecord::Migration[7.0]
  def change
    add_column :graph_protocol_test_instances, :jobs, :string, array: true, default: []
    add_column :graph_protocol_test_instances, :master_job, :string, default: nil
    add_column :graph_protocol_test_instances, :start_time, :float, default: nil
    add_column :graph_protocol_test_instances, :end_time, :float, default: nil
  end
end
