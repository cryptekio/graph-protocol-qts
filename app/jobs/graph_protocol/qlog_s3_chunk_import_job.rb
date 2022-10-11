class GraphProtocol::QlogS3ChunkImportJob < ApplicationJob
  queue_as :default

  def perform(import_id:, first_line_only: false)
    if first_line_only
      import_first_line_only(import_id: import_id)
    else
      import_everything(import_id: import_id)
    end
  end

  private

  def import_first_line_only(import_id:)
    import_job = GraphProtocol::QlogImport.find_by(:id => import_id)
    time = Time.now
    args = { range_start: import_job.range_start,
             range_end: import_job.range_end,
             key: import_job.query_set.file_path }

    first_line, remain = GraphProtocol::Util::S3::ObjectProcessor.get_object(args).body.read.split("\n",2)

    prev_seq = GraphProtocol::QlogImport.find_by(query_set_id: import_job.query_set_id,
                                                 sequence: import_job.sequence-1)

    while prev_seq.remain.nil?
      sleep 15
      puts "Previous sequence not ready yet, waiting. My seq: #{import_job.sequence}, waiting: #{import_job.sequence-1}"
    end

    line = prev_seq.remain + first_line

      begin
        json = parse_json(line)
        query = GraphProtocol::Query.new(query_set_id: import_job.query_set_id,
                                        subgraph: json[:subgraph],
                                        query: { :query => json[:query] }.to_json,
                                        variables:  json[:variables],
                                        timestamp: json[:timestamp])
        query.save
        import_job.status = :finished
      rescue JSON::ParserError
        import_job.status = :failed
        puts "Unable to parse the remains for this import job"
      end
  end

  def import_everything(import_id:)
    import_job = GraphProtocol::QlogImport.find_by(:id => import_id)
    import_job.status = :running
    time = Time.now
    args = { range_start: import_job.range_start,
             range_end: import_job.range_end,
             key: import_job.query_set.file_path }

    lines = GraphProtocol::Util::S3::ObjectProcessor.get_object(args).body.read.split("\n")

    puts "Now loading sequence number: #{import_job.sequence}"

      GraphProtocol::Util::Postgresql::Loader.execute do |copy|
        lines.each_with_index do |line,index|
          begin
            json = parse_json(line)
            copy << build_query_array(query_set_id: import_job.query_set_id,
                                    line: json,
                                    time: time)
          rescue JSON::ParserError
            handle_json_parser_error(line,index,lines.count,import_id)
          end
        end
      end

      import_job.status = :finished
  end

  def handle_json_parser_error(line, index, length,import_id)
    case index
      when 0
        GraphProtocol::QlogS3ChunkImportJob.perform_later(import_id: import_id,
                                                          first_line_only: true)
        import_job = GraphProtocol::QlogImport.find_by(:id => import_id)
        import_job.status = :waiting

      when length-1
        import_job = GraphProtocol::QlogImport.find_by(:id => import_id)
        import_job.remain = line
        import_job.status = :finished
      else
        import_job = GraphProtocol::QlogImport.find_by(:id => import_id)
        import_job.status = :failed
        raise StandardError, "Bad import job"
    end
    
  end
  
  def build_query_array(line:, query_set_id:, time:)
    [line[:subgraph], { :query => line[:query] }.to_json, line[:variables], line[:timestamp], time, time, query_set_id]
  end

  def parse_json(line)
    parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time, :query_id)
    parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
    parsed_data
  end

end
