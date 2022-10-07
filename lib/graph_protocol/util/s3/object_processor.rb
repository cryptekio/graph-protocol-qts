module GraphProtocol
  module Util
    module S3
      class ObjectProcessor
        @@s3 = nil

        def self.foreach(args)
          buffer = ""
          get_object_chunks(args) do |chunk|

            buffer = buffer + chunk.body.read
            remain = true 

            until remain.nil?
              line, remain = buffer.split("\n",2)
              unless remain.nil?
                yield line
                buffer = remain
              end
            end
          end
        end

        def self.list_objects(bucket_name:)
          bucket(bucket_name).objects
        end

        def self.get_object_size(bucket_name:, key:)
          bucket(bucket_name).object(key).size
        end

        def self.get_object(args)
          object = bucket(args[:bucket_name]).object(args[:key])

          options = {}
          options = { range: "#{args[:range_start]}-#{args[:range_end]}" } if options[:range_start] and options[:range_end]

          object.get(**options)
        end

        private

          def self.s3
            config = {}
            config[:endpoint] = ENV['AWS_S3_ENDPOINT'] if ENV['AWS_S3_ENDPOINT']
            @@s3 ||= Aws::S3::Resource.new(**config)
          end

          def self.bucket(bucket_name)
            s3.bucket(bucket_name)
          end


          def self.chunk_size
            ENV['AWS_S3_MAX_CHUNK_SIZE'].nil? ? 10000000 : ENV['AWS_S3_MAX_CHUNK_SIZE'] *1000000
          end

          def self.get_object_chunks(args)
            index = 0
            object_size = get_object_size(bucket_name: args[:bucket_name],
                                         key: args[:key]) 

            while object_size > index
              opts = {
                key: args[:key],
                bucket_name: args[:bucket_name],
                range_start: index,
                range_end: index+chunk_size
              }
              yield get_object(opts)
              index += chunk_size+1
            end 

          end

          def self.get_object(args)
            object = bucket(args[:bucket_name]).object(args[:key])

            options = {}
            options = { range: "#{args[:range_start]}-#{args[:range_end]}" } if options[:range_start] and options[:range_end]

            object.get(**options)
          end

      end
    end
  end
end
