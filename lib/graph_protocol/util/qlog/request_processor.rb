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

          hydra = Typhoeus::Hydra.new

          queries(@instance, range_start: @offset, limit: @limit).each_with_index do |query,index|

            break if cancelled?

            url = base_url + query[:subgraph]
            headers = { 'Content-Type': 'application/json' }
            req = Typhoeus::Request.new(url, 
                                        method: :post,
                                        body: request_body_json(query),
                                        headers: headers)

            req.on_complete do |resp|
              sleep_until_ready(query, @instance.sleep_enabled, @instance.start_time, @instance.speed_factor) do |offset|
                break if cancelled?
              end unless index == 0
            end

            hydra.queue(req)
          end

          hydra.run unless cancelled?
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

