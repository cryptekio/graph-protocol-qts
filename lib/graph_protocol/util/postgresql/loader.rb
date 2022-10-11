module GraphProtocol
  module Util
    module Postgresql
      class Loader

        def self.execute(query_set_id:)
          GraphProtocol::Query.copy_from_client [:subgraph, :query, :variables, :timestamp, :created_at, :updated_at, :query_set_id] do |copy|
            yield copy
          end
          #update_query_offsets(query_set_id: query_set_id)
        end

        def self.update_query_offsets(query_set_id:)
          first_query = GraphProtocol::Query.where(:query_set_id => query_set_id).minimum(:timestamp)
          GraphProtocol::Query.where(:query_set_id => query_set_id).update_all("\"offset\"=\"timestamp\"-#{first_query}")
        end

      end
    end
  end
end
