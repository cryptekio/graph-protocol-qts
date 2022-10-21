module GraphProtocol
  module Util
    module Qlog 
      class RequestLoader
        extend Helpers

        def self.execute(test_instance)
          size = queries(build_master_config(test_instance)).count
          limit = test_instance.test.chunk_size || size
          offset = 0

          while size > offset
            GraphProtocol::QlogQueryRunnerJob.perform_later(test_instance.id,
                                                            offset, limit)
            offset += limit
          end
        end

        private

          def self.build_master_config(instance)
            { :query_set_id => instance.test.query_set.id,
              #:limit => instance.test.limit || false,
              :limit => false,
              :subgraphs => instance.test.subgraphs.empty? ? false : instance.test.subgraphs }
          end

      end
    end
  end
end
