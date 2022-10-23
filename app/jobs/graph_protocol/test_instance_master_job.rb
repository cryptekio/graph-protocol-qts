class GraphProtocol::TestInstanceMasterJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2, dead: false

  def perform(id:)
    instance = GraphProtocol::Test::Instance.find_by(id: id)
    GraphProtocol::Util::Qlog::TestMaster.execute!(instance, self.provider_job_id)
  end
end
