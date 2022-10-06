module GraphProtocol
  module Util
    module Qlog 
      class RequestProcessor
        include Helpers
        include WorkerManager

        attr_accessor :test_instance_id

        def execute(args = {})

          @test_instance_id = args[:test_instance_id]

          set_start_time
          increase_workers_count
          start_time = get_start_time

          Async do
            internet = Async::HTTP::Internet.instance
            barrier = Async::Barrier.new
            semaphore = Async::Semaphore.new(args[:workers], parent: barrier)

            queries(args).each do |query|
              semaphore.async do

                sleep_until_ready(query, args, start_time)
                result = internet.post(*build_request(query))

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
            decrease_workers_count
            check_workers_and_set_end_time
          end

        end

        private

          def redis
            @redis_client ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://127.0.0.1')
          end

          def build_request(query)
            url = base_url + query[:subgraph]
            headers = [['content-type','application/json']]

            [url, headers, request_body_json(query)]
          end

          def sleep_until_ready(query, args, start_time)
            offset = get_remaining_offset(query[:offset], start_time)
            sleep offset if args[:sleep_enabled]
          end

          def get_remaining_offset(query_offset = 0.0, start_time)
            remain = query_offset - (current_time - start_time)
            remain > 0 ? remain : 0.0
          end

          def base_url
            root_path = ENV['GRAPH_GATEWAY_URL'] || "https://gateway.testnet.thegraph.com"
            root_path + "/api/" + ENV['GRAPH_GATEWAY_API_KEY'] + "/deployments/id/"
          end

          def request_body_json(query)
            body = JSON.parse(query[:query])

            unless query[:variables] == "null"
              body.merge!({:variables => JSON.parse(query[:variables])})
            end

            body.to_json
          end

      end
    end
  end
end
