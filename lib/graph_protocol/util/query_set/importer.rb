module GraphProtocol
  module Util
    module QuerySet

      class NotReady < StandardError; end

      class ImporterError < StandardError; end
      class ImporterS3Error < ImporterError 
        def message
          "Error while communicating with S3"
        end
      end
      class ImporterGzipError < ImporterError 
        def message
          "Unable to extract gzip archive"
        end
      end
      class ImporterS3CredentialsError < ImporterError
        def message
          "Invalid or missing S3 credentials"
        end
      end
      class ImporterS3NoSuchFile < ImporterError
        def message
          "File not found in S3"
        end
      end

      class ImporterInterrupt < ImporterError
        def message
          "Import job canceled"
        end
      end



      class Importer

        def self.execute!(query_set, reimport: true)
          begin
            time = Time.now
            tmp_file = s3_download(query_set)

            clear_old_queries(query_set) if reimport

            import_to_psql(query_set) do |copy|
              read_by_line(tmp_file) do |line|
                write_query(query_set_id: query_set.id,
                            psql_handler: copy,
                            time: time,
                            line: line)
              end
            end

          rescue SignalException
            raise ImporterInterrupt
          rescue Aws::S3::Errors::InvalidAccessKeyId
            raise ImporterS3CredentialsError
          rescue Aws::S3::Errors::NoSuchKey
            raise ImporterS3NoSuchFile
          rescue Aws::Sigv4::Errors::MissingCredentialsError
            raise ImporterS3CredentialsError
          rescue Seahorse::Client::NetworkingError
            raise ImporterS3Error
          rescue Zlib::GzipFile::Error
            raise ImporterGzipError

          ensure
            cleanup(tmp_file) if tmp_file
          end
        end

        def self.clear_old_queries(query_set)
          query_set.queries.delete_all
        end

        def self.cleanup(tmp_file)
          File.delete(tmp_file) if File.exists?(tmp_file)
        end

        def self.s3_download(query_set)
          key = query_set.file_path
          tmp_file = tmp_dir + "/import_" + rand(36**12).to_s(36)

          File.open(tmp_file, 'wb') do |file|
            GraphProtocol::Util::S3::ObjectProcessor.download_file(key: key, file: file)
          end

          tmp_file
        end

        def self.read_by_line(file)
          if json_file?(file)
            read_file_by_line(file) do |line|
              yield line
            end
          else
            read_gzip_by_line(file) do |line|
              yield line
            end
          end
        end

        def self.read_gzip_by_line(file)
          Zlib::GzipReader.open(file) do |gz|
            gz.each_line do |line|
              yield line
            end
          end
        end

        def self.read_file_by_line(file)
          File.readlines(file).each do |line|
            yield line
          end
        end

        def self.json_file?(file)
          `file --brief --mime-type #{file}`.strip == "application/json"
        end

        def self.tmp_dir
          ENV['TMP_DIR'] || '/tmp/imports'
        end

        def self.import_to_psql(query_set)
          GraphProtocol::Util::Postgresql::Loader.execute!(query_set_id: query_set.id) do |copy|
            yield copy
          end
        end

        def self.write_query(psql_handler:, line:, query_set_id:, time:)
          begin
            psql_handler << build_query_array(line: parse_json(line),
                                              query_set_id: query_set_id,
                                              time: time)
          rescue JSON::ParserError
            return true 
          end
        end

        def self.build_query_array(line:, query_set_id:, time:)
          [line[:subgraph], { :query => line[:query] }.to_json, line[:variables], line[:timestamp], time, time, query_set_id]
        end

        def self.parse_json(line)
          parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time, :query_id)
          parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
          parsed_data
        end

      end
    end
  end
end
