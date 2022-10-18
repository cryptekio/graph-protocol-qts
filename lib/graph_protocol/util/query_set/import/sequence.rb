module GraphProtocol
  module Util
    module QuerySet
      module Import
        class Sequence

          EXCLUDE_JSON_FIELDS = [:block, :time, :query_id]

          def self.execute!(sequence_id:)
            puts "Finding sequence #{sequence_id}"
            sequence = GraphProtocol::QuerySetSequenceImport.find_by(id: sequence_id)
            puts "Executing sequence #{sequence_id}"
            sequence.set_status = :importing
            s3_key = sequence.query_set.file_path
            rstart = sequence.range_start
            rend = sequence.range_end

            buffer = GraphProtocol::Util::S3::ObjectProcessor.get_object(key: s3_key,
                                                               range_start: rstart,
                                                               range_end: rend).body.read

            rindex = buffer.bytes.rindex(10) # 10 == \n
            
            return if rindex.nil?

            lines = buffer.byteslice(0,rindex).split("\n")
            write_queries(lines, sequence)

            sequence.set_status = :ready

          end

          private

            def self.write_queries(lines, sequence)
              time = Time.now
              query_set_id = sequence.query_set.id
              GraphProtocol::Util::Postgresql::Loader.execute!(query_set_id: query_set_id) do |copy|
                lines.each_with_index do |line, index|
                  json_result = json_parsable?(line)

                  if json_result
                    copy << build_query_array(query_set_id: query_set_id,
                                              time: time,
                                              line: json_result)
                  else
                    evaluate_json_failure(lines,index,sequence)
                  end

                end
              end
            end

            def self.evaluate_json_failure(lines, index, sequence)
              case index
              when 0
                sequence.set_prefix = lines[index]
              when lines.count-1
                sequence.set_suffix = lines[index] 
              else
                puts "JSON parse failure at index #{index} for line: #{lines[index]}"
              end
            end

            def self.build_query_array(line:, query_set_id:, time:)
              [line[:subgraph], { :query => line[:query] }.to_json, line[:variables], line[:timestamp], time, time, query_set_id]
            end

            def self.json_parsable?(line)
              begin
                result = JSON.parse(line.chomp,
                                    symbolize_names: true).except(*EXCLUDE_JSON_FIELDS) 
                result[:timestamp] = DateTime.parse(result[:timestamp]).to_f
                result
              rescue JSON::ParserError
                false
              end
            end

        end
      end
    end
  end
end
