module GraphProtocol
  module Util
    class Redis

      def queue_push(queue:, data:)
        redis.rpush(queue,data)
      end

      def queue_pop(queue:)
        redis.lpop(queue)
      end

      def queue_pop_all(queue:)
        redis.lrange(queue,0,-1)
      end

      def queue_length(queue:)
        redis.llen(queue)
      end

      private
        def redis
          @redis_client ||= Redis.new(url: ENV['REDIS_URL'] || 'redis://127.0.0.1')
        end
    end
  end
end
