class GraphProtocol::QlogQueryRunnerJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0, dead: false 

  def perform(test_instance_id, offset, limit)
    processor = GraphProtocol::Util::Qlog::RequestProcessor.new(test_instance_id,
                                                                offset, limit,
                                                                self.provider_job_id)
    processor.execute
  end

end
