module GraphProtocol
  module Util
    module QuerySet
      class Importer
        def self.execute!(query_set_id: )
          query_set = GraphProtocol::QuerySet.find_by(:id => query_set_id)
          #import_qlog_from_s3_v2(query_set)
          chunk_import_qlog_from_s3(query_set)
        end

        private

          def self.chunk_import_qlog_from_s3(set)
            size = GraphProtocol::Util::S3::ObjectProcessor.get_object_size(key: set.file_path)
            chunk_size = GraphProtocol::Util::S3::ObjectProcessor.chunk_size
            seq = 0
            index = 0
            set_status_importing(set)

            while size > index
              cfg = { query_set: set,
                      sequence: seq,
                      status: 0,
                      range_start: index,
                      range_end: index+chunk_size
              }
              import_job = GraphProtocol::QlogImport.new(cfg)
              import_job.save

              GraphProtocol::QlogS3ChunkImportJob.perform_later(import_id: import_job.id)

              index += chunk_size+1
              seq += 1
            end

          end

          def self.import_qlog_from_s3(set)
            begin
              s3_cfg = { :key => set.file_path, :query_set_id => set.id }
              psql_cfg = { :query_set_id => set.id }
              set_status_importing(set)
              GraphProtocol::Util::Postgresql::Loader.execute(**psql_cfg) do |copy|
                GraphProtocol::Util::S3::ObjectProcessor.foreach_json(**s3_cfg) do |query|
                  copy << query
                end
              end
              set_status_ready(set)
            #rescue Exception => exc
            #  puts exc.message
            #  set_status_failed(set)
            end
          end

          def self.import_qlog_from_s3_v2(set)
            begin
              s3_cfg = { :key => set.file_path }
              set_status_importing(set)
              GraphProtocol::Util::S3::ObjectProcessor.foreach_buffer_chunk(**s3_cfg) do |chunk|
                GraphProtocol::QuerySetChunkImportJob.perform_later(query_set_id: set.id,
                                                                    chunk: chunk)
              end

            # wait to finish somehow, and update query offsets at the end
             
              set_status_ready(set)
            #rescue Exception => exc
            #  puts exc.message
            #  set_status_failed(set)
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
