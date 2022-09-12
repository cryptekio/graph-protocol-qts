
require 'async'
require 'async/barrier'
require 'async/http/internet/instance'

module GraphProtocol
  class AsyncRequestManager

    def self.fire_requests!(args = {})

      workers = args[:workers] || 10
      queries = args[:queries]

      Async do
        internet = Async::HTTP::Internet.instance
        barrier = Async::Barrier.new
        semaphore = Async::Semaphore.new(workers, parent: barrier)

        queries.each do |query|
          semaphore.async do
            #sleep query[:offset]
            url = ENV['GRAPH_GATEWAY_URL'] + "/api/" + ENV['GRAPH_GATEWAY_API_KEY'] + "/subgraphs/id/" + query[:subgraph]
            headers = [['content-type','application/json']]

            result = internet.post(url, headers, query[:query])

            puts "#{query[:query_id]} : #{JSON.parse(result.read)}"
          end
        end

        barrier.wait
      ensure
        internet&.close
      end
    end

  end
end
