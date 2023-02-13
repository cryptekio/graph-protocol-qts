require 'sidekiq/api'

module GraphProtocol
  module Util
    module Qlog
      class TestMaster
        extend Helpers

        def self.execute!(test_instance, jid)

          begin
            test_instance.set_status :running
            test_instance.set_master_jid jid

            size = queries(test_instance).count
            limit = test_instance.chunk_size || size
            offset = 0
            test_instance.start_time = current_time 

            while size > offset
              return if cancelled?(test_instance)
              first_query = queries(test_instance,
                                    range_start: offset,
                                    limit: 1).first
              sleep_until_ready(first_query, test_instance.sleep_enabled, test_instance.start_time, test_instance.speed_factor) do |offset|
                break if cancelled?(test_instance)
              end

              return if cancelled?(test_instance)

              job = GraphProtocol::QlogQueryRunnerJob.perform_later(test_instance.id,
                                                                    offset,
                                                                    limit)
              test_instance.add_jid(job.provider_job_id)

              offset += limit

              if test_instance.loop? and offset >= size
                test_instance.start_time = current_time
                offset = 0
              end

            end

            sleep_until_workers_finish(test_instance)

            test_instance.set_status :finished
          rescue SignalException
            cancel!
            return
          end
        end

        # wait for workers to finish
        # this is sidekiq specific
        def self.sleep_until_workers_finish(test_instance)
          running = true

          while running
            return if cancelled?(test_instance)
            workers = Sidekiq::Workers.new
            worker_jids = []
            workers.each do |jid, thread_id, work|
              worker_jids << jid
            end

            remaining_jobs = test_instance.jobs & worker_jids

            if remaining_jobs.empty?
              running = false
              break
            end

            sleep 5
          end
        end

        def self.cancelled?(test_instance)
          jid = test_instance.master_job
          Sidekiq.redis { |c| c.exists?("cancelled-#{jid}") }
        end

        def self.cancel!(test_instance)

          jid = test_instance.master_job
          Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 86400, 1) }

          test_instance.jobs.each do |job|
            GraphProtocol::Util::Qlog::RequestProcessor.cancel!(job)
          end

          test_instance.set_status :stopped
        end

      end
    end
  end
end
