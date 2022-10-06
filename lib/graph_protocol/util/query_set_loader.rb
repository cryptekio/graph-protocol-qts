module GraphProtocol
  module Util
    class QuerySetLoader

      def self.execute(args)
        GraphProtocol::Query.copy_from_client [:subgraph, :query_id, :query, :variables, :timestamp, :created_at, :updated_at, :query_set_id] do |copy|
          read_queries_from_file(args) do |data|
            time = Time.now
            copy << [data[:subgraph], data[:query_id], { :query => data[:query] }.to_json, data[:variables], data[:timestamp], time, time, args[:query_set_id]]
          end
        end
        update_query_offsets(args)
      end

      private

      def read_queries_from_file(args)
        File.foreach(args[:filename]) do |line|
          parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time)
          parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
          yield parsed_data
        end
      end

      def update_query_offsets(args)
        first_query = GraphProtocol::Query.where(:query_set_id => args[:query_set_id]).minimum(:timestamp)
        GraphProtocol::Query.where(:query_set_id => args[:query_set_id]).update_all("\"offset\"=\"timestamp\"-#{first_query}")
      end

    end
  end
end
