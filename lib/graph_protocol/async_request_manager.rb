
require 'async'
require 'async/barrier'
require 'async/http/internet/instance'

module GraphProtocol
  class AsyncRequestManager

    def fire_requests!(args = {})

      config = { :sleep_enabled => args[:sleep_enabled] || true,
                 :query_set => args[:query_set],
                 :limit => args[:limit] || false,
                 :subgraphs => args[:subgraphs] || false,
                 :workers => args[:workers] || 50 }

      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      Async do
        internet = Async::HTTP::Internet.instance
        barrier = Async::Barrier.new
        semaphore = Async::Semaphore.new(config[:workers], parent: barrier)

        queries(config).each do |query|
          semaphore.async do

            sleep get_remaining_offset(query[:offset]) if config[:sleep_enabled]

            url = base_url + query[:subgraph]
            headers = [['content-type','application/json']]
            req_body = JSON.parse(query[:query])

            unless query[:variables] == "null"
              req_body.merge!({:variables => JSON.parse(query[:variables])})
            end

            result = internet.post(url, headers, req_body.to_json)

            puts "#{query[:query_id]} : #{JSON.parse(result.read)}"
          end
        end

        barrier.wait
      ensure
        internet&.close
      end
    end

    private

      def queries(config = {})
        base = config[:subgraphs] ? config[:query_set].queries.subgraphs(config[:subgraphs]) : config[:query_set].queries

        result = config[:limit] ? base.sort_by_offset.limit(config[:limit]) : base.sort_by_offset 
        result
      end

      def base_url
        root_path = ENV['GRAPH_GATEWAY_URL'] || "https://gateway.testnet.thegraph.com"
        api_key = ENV['GRAPH_GATEWAY_API_KEY']

        root_path + "/api/" + api_key + "/deployments/id/"
      end

      def get_remaining_offset(query_offset = 0.0)
        remain = query_offset - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time)
        result = remain > 0 ? remain : 0.0

        result
      end

  end
end
