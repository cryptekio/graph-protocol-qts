module GraphProtocol
  module Util
    module QuerySet
      class Importer
        def self.execute!(query_set_id: )
          query_set = GraphProtocol::QuerySet.find_by(:id => query_set_id)
          import_qlog_from_s3_v2(query_set)
        end

        private

          def self.import_qlog_from_s3_v2(set)
            begin
              s3_cfg = { :key => set.file_path }
              set_status_importing(set)
              buffer = ""
              GraphProtocol::Util::S3::ObjectProcessor.get_object_chunks(**s3_cfg) do |chunk|
                buffer = buffer + chunk.body.read
                rindex = true
                until rindex.nil?
                  rindex = buffer.rindex("\n")
                  unless rindex.nil?
                    GraphProtocol::QuerySetChunkImportJob.perform_later(lines: buffer[0..rindex],
                                                                        query_set_id: set.id)
                    buffer = buffer[rindex+1..buffer.length-1]
                  end
                end
              end
              set_status_ready(set)
            #rescue Exception => exc
            #  puts exc.message
            #  set_status_failed(set)
            end
          end


          def self.import_qlog_from_s3(set)
            begin
              s3_cfg = { :key => set.file_path }
              set_status_importing(set)
              buffer = ""
              GraphProtocol::Util::S3::ObjectProcessor.get_object_chunks(**s3_cfg) do |chunk|
                buffer = buffer + chunk.body.read
                remain = true
                until remain.nil?
                  last_line, remain = buffer.reverse.split("\n", 2)
                  GraphProtocol::QuerySetChunkImportJob.perform_later(query_set_id: set.id,
                                                                      lines: remain.reverse) unless remain.nil?
                  buffer = last_line.reverse unless last_line.nil?
                end
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
