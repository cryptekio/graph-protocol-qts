module GraphProtocol
  module Util
    module Qlog 
      module Helpers

        def current_time
          Process.clock_gettime(Process::CLOCK_MONOTONIC)
        end

        def queries(args)
          query_set = GraphProtocol::QuerySet.find_by(:id => args[:query_set_id])
          query_set.queries.subgraphs(args[:subgraphs]).sort_by_delay.set_offset(args[:query_range_start]).set_limit(args[:limit])
        end

      end
    end
  end
end
