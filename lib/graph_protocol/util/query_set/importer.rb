module GraphProtocol
  module Util
    module QuerySet
      class Importer

        def self.schedule_import_job(query_set:, range_start: 0, object_size:)
          GraphProtocol::QuerySetChunkImportJob.perform_later(
            range_start: range_start,
            query_set_id: query_set.id,
            object_size: object_size,
            chunk_size: GraphProtocol::Util::S3::ObjectProcessor.chunk_size
          )
        end

        def self.import_qlog_chunk_from_s3(query_set:, range_start:, object_size:, chunk_size:)
          query_set_id = query_set.id
          range_end = range_start + chunk_size

          puts "Fetching buffer: start: #{range_start}, end: #{range_end} object_size: #{object_size}"

          args = { key: query_set.file_path,
                   range_start: range_start,
                   range_end: range_end }
          buffer = GraphProtocol::Util::S3::ObjectProcessor.get_object(args).body.read

          rindex = buffer.rindex("\n")
          next_range_start = rindex.nil? ? range_start : range_start+rindex+1

          schedule_import_job(query_set: query_set,
                              range_start: next_range_start,
                              object_size: object_size
                             ) unless range_end >= object_size

          return if rindex.nil?

          time = Time.now
          lines = buffer[0..rindex-1].split("\n")
          GraphProtocol::Util::Postgresql::Loader.execute!(query_set_id: query_set_id) do |copy|
            lines.each_with_index do |line, index|
              begin
                copy << build_query_array(query_set_id: query_set_id,
                                          time: time,
                                          line: line)
              rescue JSON::ParserError
                puts "Index: #{index}"
                puts "Line: #{line}"
              end

            end
          end

        end

        private
          def self.build_query_array(line:, query_set_id:, time:)
            json_output = parsed_json(line)
            [json_output[:subgraph], { :query => json_output[:query] }.to_json, json_output[:variables], json_output[:timestamp], time, time, query_set_id]
          end

          def self.parsed_json(line)
            parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time, :query_id)
            parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
            parsed_data
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
