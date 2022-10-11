class GraphProtocol::QuerySetChunkImportJob < ApplicationJob
  queue_as :default

  def perform(query_set_id:, chunk:)
    time = Time.now
    GraphProtocol::Util::Postgresql::Loader.execute(query_set_id: query_set_id) do |copy|
      chunk.split("\n").each do |line|
        copy << build_query_array(query_set_id: query_set_id,
                                  time: time,
                                  line: line)
      end
    end
  end

  private

    def build_query_array(line:, query_set_id:, time:)
      json_output = parsed_json(line)
      [json_output[:subgraph], { :query => json_output[:query] }.to_json, json_output[:variables], json_output[:timestamp], time, time, query_set_id]
    end

    def parsed_json(line)
      parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time, :query_id)
      parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
      parsed_data
    end
end
