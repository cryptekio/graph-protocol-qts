class TestsAddLoopFeature < ActiveRecord::Migration[7.0]
  def change
    add_column :graph_protocol_tests, :loop_queries, :boolean, default: false 
  end
end
