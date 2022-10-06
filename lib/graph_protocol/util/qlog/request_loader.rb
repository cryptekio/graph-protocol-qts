module GraphProtocol
  module Util
    module Qlog 
      class RequestLoader
        extend Helpers

        def self.execute(args = {})

          size = queries(build_master_config(args)).count
          limit = args[:query_set_chunk_size] || size
          offset = 0

          while size > offset
            cfg = build_job_config(args, offset, limit)
            send_job(cfg)
            offset += limit
          end
        end

        private

          def self.send_job(args = {})
            GraphProtocol::QlogQueryRunnerJob.perform_later(args)
          end

          def self.build_master_config(args)
            { :query_set_id => args[:query_set_id],
              :limit => args[:limit] || false,
              :subgraphs => args[:subgraphs] || false }
          end

          def self.build_job_config(args, offset, limit)
            { :query_set_id => args[:query_set_id],
              :test_instance_id => args[:test_instance_id],
              :limit => limit,
              :query_range_start => offset,
              :subgraphs => args[:subgraphs] || false,
              :workers => args[:workers] || 50,
              :sleep_enabled => args[:sleep_enabled].nil? ? true : args[:sleep_enabled] }
          end

      end
    end
  end
end
