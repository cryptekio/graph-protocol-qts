class GraphProtocol::TestInstanceJob < ApplicationJob
  queue_as :default

  def perform(test_instance_id:)
    instance = GraphProtocol::Test::Instance.find_by(id: test_instance_id)
    GraphProtocol::Util::Qlog::TestMaster.execute!(instance)
  end
end
