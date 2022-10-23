module GraphProtocol
  module Util
    module Qlog 
      module Helpers

        def current_time
          Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def queries(test_instance, range_start: false, limit: false)
          query_limit = limit || test_instance.query_limit
          query_set = test_instance.query_set
          query_set.queries.subgraphs(test_instance.subgraphs).sort_by_delay.set_offset(range_start).set_limit(query_limit)
        end

        def sleep_until_ready(query, sleep_enabled, start_time)
          offset = get_remaining_offset(query[:offset], start_time)
          sleep offset if sleep_enabled
        end

        def get_remaining_offset(query_offset = 0.0, start_time)
          remain = query_offset - (current_time - start_time)
          remain > 0 ? remain : 0.0
        end

      end
    end
  end
end
