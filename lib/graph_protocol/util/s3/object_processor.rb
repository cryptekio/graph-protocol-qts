module GraphProtocol
  module Util
    module S3
      class ObjectProcessor
        @@s3 = nil

        def self.foreach_json(key:, query_set_id:)
          buffer = ""
          get_object_chunks(key: key) do |chunk|

            buffer = buffer + chunk.body.read
            remain = true
            result = []
            time = Time.now

            until remain.nil?
              line, remain = buffer.split("\n",2)
              unless remain.nil?
                yield build_query_array(line: line,
                                        time: time,
                                        query_set_id: query_set_id)
                buffer = remain
              end
            end

          end
        end

        def self.list_objects
          bucket.objects
        end

        def self.get_object_size(key:)
          bucket.object(key).size
        end

        def self.get_object(args)
          object = bucket.object(args[:key])

          options = {}
          options = { range: "bytes=#{args[:range_start]}-#{args[:range_end]}" } if args[:range_start] and args[:range_end]

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
            client = Aws::S3::Client.new(retry_limit: 12,
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
              yield get_object(opts)
              index += chunk_size+1
            end 

          end

      end
    end
  end
end
