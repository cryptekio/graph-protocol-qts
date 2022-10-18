module GraphProtocol
  module Util
    module S3
      class ObjectProcessor
        @@s3 = nil

        def self.foreach_buffer_chunk(key:)
          buffer = ""
          get_object_chunks(key: key) do |chunk|
            buffer = buffer + chunk.body.read
            remain = true

            until remain.nil?
              last_line, remain = buffer.reverse.split("\n", 2)
              unless remain.nil?
                yield remain.reverse
              end
              buffer = last_line.reverse unless last_line.nil?
            end

          end
        end


        def self.list_objects
          bucket.objects
        end

        def self.get_object_size(key:)
          bucket.object(key).size
        end

        def self.get_object(key:, range_start: nil, range_end: nil)
          object = bucket.object(key)

          options = {}
          options = { range: "bytes=#{range_start}-#{range_end}" } if range_start and range_end

          object.get(**options)
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

          def self.s3
            client = Aws::S3::Client.new(retry_limit: 5,
                                         retry_backoff: lambda { |c| sleep(5) })
            config = {:client => client}
            config[:endpoint] = ENV['AWS_S3_ENDPOINT'] if ENV['AWS_S3_ENDPOINT']
            @@s3 ||= Aws::S3::Resource.new(**config)
          end

          def self.bucket
            s3.bucket(ENV['AWS_S3_BUCKET'])
          end


          def self.chunk_size
            ENV['AWS_S3_MAX_CHUNK_SIZE'].nil? ? 100000000 : ENV['AWS_S3_MAX_CHUNK_SIZE'].to_i*1000000 # 100mb default
          end

          def self.get_object_chunks(key: )
            index = 0
            object_size = get_object_size(key: key)

            while object_size > index
              opts = {
                key: key,
                range_start: index,
                range_end: index+chunk_size
              }
              yield get_object(**opts)
              index += chunk_size+1
            end 

          end

      end
    end
  end
end
