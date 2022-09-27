
require 'async'
require 'async/barrier'
require 'async/http/internet/instance'

module GraphProtocol
  class AsyncRequestManager

    def load_requests(args = {})

      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      config = { :query_set_id => args[:query_set_id],
                 :limit => args[:limit] || false,
                 :subgraphs => args[:subgraphs] || false }
      size = queries(config).count
      offset = 0
      limit = args[:query_set_chunk_size] || size 

      while size > offset 
        cfg = { :sleep_enabled => args[:sleep_enabled] || true,
                :start_time => start_time,
                :query_set_id => args[:query_set_id],
                :query_range_start => offset,
                :limit => limit,
                :subgraphs => args[:subgraphs] || false,
                :workers => args[:workers] || 50 }
        send_job(cfg)
        offset += limit
      end
    end

    def send_job(args = {})
      GraphProtocol::QueryTestJob.perform_later(args)
    end

    def process_requests(args = {})

      Async do
        internet = Async::HTTP::Internet.instance
        barrier = Async::Barrier.new
        semaphore = Async::Semaphore.new(args[:workers], parent: barrier)

        queries(args).each do |query|
          semaphore.async do

            remaining = get_remaining_offset(query[:offset], args[:start_time])
            #puts "#{query[:query_id]}, query offset: #{query[:offset]}, sleep: #{remaining}"
            sleep remaining if args[:sleep_enabled]

            url = base_url + query[:subgraph]
            headers = [['content-type','application/json']]
            req_body = JSON.parse(query[:query])

            unless query[:variables] == "null"
              req_body.merge!({:variables => JSON.parse(query[:variables])})
            end

            result = internet.post(url, headers, req_body.to_json)

            unless result.success?
              puts "Failed query: #{query[:query_id]}"
              puts "#{result.inspect}"
            end
          ensure
            result&.close
          end
        end

        barrier.wait
      ensure
        internet&.close
      end
    end

    private

      def queries(config = {})
        query_set = GraphProtocol::QuerySet.find_by(:id => config[:query_set_id])
        query_set.queries.subgraphs(config[:subgraphs]).sort_by_delay.set_offset(config[:query_range_start]).set_limit(config[:limit])
      end

      def base_url
        root_path = ENV['GRAPH_GATEWAY_URL'] || "https://gateway.testnet.thegraph.com"
        root_path + "/api/" + ENV['GRAPH_GATEWAY_API_KEY'] + "/deployments/id/"
      end

      def get_remaining_offset(query_offset = 0.0, start_time)
        remain = query_offset - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time)
        remain > 0 ? remain : 0.0
      end

  end
end
