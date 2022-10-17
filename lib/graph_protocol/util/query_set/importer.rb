module GraphProtocol
  module Util
    module QuerySet
      class Importer

        def self.schedule_import_job(query_set:, range_start: 0, object_size: nil)
          size = object_size.nil? GraphProtocol::Util::S3::ObjectProcessor.get_object_size(key: query_set.file_path) : object_size

          GraphProtocol::QuerySetChunkImportJob.perform_later(
            range_start: range_start,
            query_set_id: query_set.id,
            object_size: size,
            chunk_size: GraphProtocol::Util::S3::ObjectProcessor.chunk_size
          )
        end

        def self.import_qlog_chunk_from_s3(query_set:, range_start:, object_size:, chunk_size:)
          query_set_id = query_set.id
          range_end = range_start + chunk_size-1

          args = { key: query_set.file_path,
                   range_start: range_start,
                   range_end: range_end }
          buffer = GraphProtocol::Util::S3::ObjectProcessor.get_object(args).body.read

          rindex = buffer.bytes.rindex(10) # 10 == \n 
          next_range_start = rindex.nil? ? range_start : range_start+rindex+1

          schedule_import_job(query_set: query_set,
                              range_start: next_range_start,
                              object_size: object_size
                             ) unless range_end >= object_size # and already scheduled?

          return if rindex.nil?

          #lines = buffer.byteslice(0,rindex).split("\n")
          lines = buffer.byteslice(0,rindex)
          write_queries(lines, query_set_id)

        end

        private

          def self.write_queries(lines, query_set_id)
            time = Time.now
            GraphProtocol::Util::Postgresql::Loader.execute!(query_set_id: query_set_id) do |copy|
              slice_by_newline(lines) do |line|
                copy << build_query_array(query_set_id: query_set_id,
                                          time: time,
                                          line: line)
              end
            end
          end

          def self.slice_by_newline(buffer)
            result, remain = buffer.split("\n",2)
            until remain.nil?
              yield result
              result, remain = remain.split("\n",2)
            end
          end

          def self.build_query_array(line:, query_set_id:, time:)
            json_output = parsed_json(line)
            [json_output[:subgraph], { :query => json_output[:query] }.to_json, json_output[:variables], json_output[:timestamp], time, time, query_set_id]
          end

          def self.parsed_json(line)
            begin
              parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time, :query_id)
              parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
              parsed_data
            rescue JSON::ParserError
              puts "Failed to parse query: #{line.chomp}"
              {}
            end
          end

          def self.set_status_importing(query_set)
            query_set.status = :importing
            query_set.save
          end

          def self.set_status_ready(query_set)
            query_set.status = :ready
            query_set.save
          end

          def self.set_status_failed(query_set)
            query_set.status = :failed
            query_set.save
          end

      end
    end
  end
end
