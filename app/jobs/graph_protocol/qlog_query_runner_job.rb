class GraphProtocol::QlogQueryRunnerJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: false

  def perform(args = {})
    processor = GraphProtocol::Util::Qlog::RequestProcessor.new
    processor.execute(args) 
  end

end
