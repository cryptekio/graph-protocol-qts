module GraphProtocol
  module Util
    module QuerySet
      module Import
        class Master

          def initialize(query_set_id:)
            @query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)
            @chunk_size = GraphProtocol::Util::S3::ObjectProcessor.chunk_size
            @total_sequences = 0
          end

          def execute!
            @query_set.set_status = :importing
            @query_set.set_object_size = GraphProtocol::Util::S3::ObjectProcessor.get_object_size(key: @query_set.file_path)


            schedule_all_sequences

            until finished?
              print_status_info
              sleep 30
            end

            remaining_queries = []

            load_suffixes do |query|
              remaining_queries << query
            end

            puts remaining_queries

            @query_set.set_status = :ready
          end

          private

          def load_suffixes
            @query_set.reload
            @query_set.query_set_sequence_imports.each do |seq|
              yield seq.get_suffix_query
            end
          end

          def print_status_info
            @query_set.reload
            seq_total = @query_set.query_set_sequence_imports.count
            seq_finished = @query_set.query_set_sequence_imports.where('status > 1').count 
            seq_running = @query_set.query_set_sequence_imports.where(status: 1).count

            puts "SEQ_EXPECTED: #{@total_sequences}, SEQ_TOTAL: #{seq_total}, SEQ_FINISHED: #{seq_finished}, SEQ_RUNNING:#{seq_running}"
          end

          def finished?
            @query_set.reload
            non_finished = @query_set.query_set_sequence_imports.where('status < 2').count

            non_finished > 0 ? false : true
          end

          def schedule_all_sequences
            range_start = 0
            seq_index = 0

            until range_start >= @query_set.object_size
              range_end = range_start + @chunk_size-1
              seq = @query_set.create_sequence(index: seq_index,
                                               range_start: range_start,
                                               range_end: range_end)
              seq.import!
              
              range_start += @chunk_size
              seq_index += 1
              @total_sequences += 1
            end
          end

        end
      end
    end
  end
end
