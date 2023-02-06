require 'async/http/internet/instance' 
require 'async/barrier'
require 'async/semaphore'

module GraphProtocol
  module Util
    module Qlog 
      class RequestProcessor
        include Helpers

        def initialize(test_instance_id, offset, limit, jid)
          @instance = GraphProtocol::Test::Instance.find_by(id: test_instance_id)
          @offset = offset
          @limit = limit
          @jid = jid
        end

        def execute

          Async do
            internet = Async::HTTP::Internet.instance
            barrier = Async::Barrier.new
            semaphore = Async::Semaphore.new(@instance.workers, parent: barrier)

            queries(@instance, range_start: @offset, limit: @limit).each_with_index do |query,index|
              if cancelled?
                internet&.close
                break  
              end

              semaphore.async do

                sleep_until_ready(query, @instance.sleep_enabled, @instance.start_time) do |offset|
                  break if cancelled?
                end unless index == 0

                break if cancelled?

                result = internet.post(*build_request(query))

                #unless result.success?
                #  puts "Failed query: #{query[:query_id]}"
                #  puts "#{result.inspect}"
                #end
              ensure
                result&.close
              end
            end

            break if cancelled?
            barrier.wait
          ensure
            internet&.close
          end

        end

          def build_request(query)
            url = base_url + query[:subgraph]
            headers = [['content-type','application/json']]

            [url, headers, request_body_json(query)]
          end

          def base_url
            root_path = @instance.gateway_url || "https://gateway.testnet.thegraph.com"
            root_path + "/api/" + @instance.api_key + "/deployments/id/"
          end

          def request_body_json(query)
            body = JSON.parse(query[:query])

            unless query[:variables] == "null"
              body.merge!({:variables => JSON.parse(query[:variables])})
            end

            body.to_json
          end

          def cancelled?
            Sidekiq.redis {|c| c.exists?("cancelled-#{@jid}") }
          end

          def self.cancel!(jid)
            Sidekiq.redis {|c| c.setex("cancelled-#{jid}", 86400, 1) }
          end

      end
    end
  end
end

