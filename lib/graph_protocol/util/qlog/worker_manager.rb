module GraphProtocol
  module Util
    module Qlog
      module WorkerManager 

        def increase_workers_count
          puts "Increasing worker count"
          redis.incr(workers_key)
        end

        def decrease_workers_count
          puts "Decreasing worker count"
          redis.decr(workers_key)
        end

        def get_workers_count
          redis.get(workers_key).to_f
        end


        def set_start_time
          if redis.set(start_time_key, current_time, nx: true)
            @instance.set_status = :running
          end
        end

        def get_start_time
          redis.get(start_time_key).to_f
        end


        def check_workers_and_set_end_time
          if get_workers_count == 0
            redis.set(end_time_key, current_time, nx: true)
            @instance.set_status = :finished
            # check if previous set returns false (if yes raise exception)
          end
        end

        private

          def key_root
            "qlog::" + @instance.id + "::"
          end

          def workers_key
            key_root + "workers"
          end

          def start_time_key
            key_root + "start_time"
          end

          def end_time_key
            key_root + "end_time"
          end

      end
    end
  end
end
