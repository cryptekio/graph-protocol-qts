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

        def sleep_until_ready(query, sleep_enabled, start_time, speed_factor = 1.0)
          offset = get_remaining_offset(query[:offset], start_time) / speed_factor
          if sleep_enabled
            while offset > 1
              sleep 1
              offset = offset - 1
              yield offset
            end
            sleep offset
          end

        end

        def get_remaining_offset(query_offset = 0.0, start_time)
          remain = query_offset - (current_time - start_time)
          remain > 0 ? remain : 0.0
        end

      end
    end
  end
end
