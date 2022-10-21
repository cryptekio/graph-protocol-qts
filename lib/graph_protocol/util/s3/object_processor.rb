module GraphProtocol
  module Util
    module S3
      class ObjectProcessor
        @@s3 = nil

        def self.list_objects
          bucket.objects
        end

        def self.get_object_size(key:)
          bucket.object(key).size
        end

        def self.download_file(key:, file:)
          s3.client.get_object( { bucket: bucket_name, key: key },
                               target: file)
        end

        def self.get_object_attributes(key:, attrs:)
          s3.client.get_object_attributes( { bucket: bucket_name,
                                             key: key,
                                             object_attributes: attrs } )
        end

        def self.get_object_checksums(key:)
          get_object_attributes(key: key, attrs: [ "Checksum" ])
        end

        def self.get_object(args)
          object = bucket.object(args[:key])

          options = {}
          options = { range: "bytes=#{args[:range_start]}-#{args[:range_end]}" } if args[:range_start] and args[:range_end]

          object.get(**options)
        end

        private

          def self.s3
            client_config = {
              retry_limit: 5,
              retry_backoff: lambda { |c| sleep(5) }
            }
            client_config[:endpoint] = ENV['AWS_S3_ENDPOINT'] if ENV['AWS_S3_ENDPOINT']
            client = Aws::S3::Client.new(**client_config)
            config = {:client => client}

            @@s3 ||= Aws::S3::Resource.new(**config)
          end

          def self.bucket_name
            ENV['AWS_S3_BUCKET']
          end

          def self.bucket
            s3.bucket(ENV['AWS_S3_BUCKET'])
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
