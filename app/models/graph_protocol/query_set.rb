class GraphProtocol::QuerySet < ApplicationRecord
  has_many :queries, dependent: :destroy
  after_initialize :set_uuid

  def load_data(args = {})

    # Pull queries line by line from file and push them to PSQL using copy_from_client
    GraphProtocol::Query.copy_from_client [:subgraph, :query_id, :query, :variables, :timestamp, :created_at, :updated_at, :query_set_id] do |copy|
      File.foreach(args[:filename]) do |line|
        parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time)
        parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
        formatted_query = { :query => parsed_data[:query] }.to_json
        time = Time.now
        copy << [parsed_data[:subgraph], parsed_data[:query_id], formatted_query, parsed_data[:variables], parsed_data[:timestamp], time, time, self.id]
      end
    end

    # Once in PSQL, update query offsets by finding the first query and offsetting from there
    first_query = GraphProtocol::Query.where(:query_set_id => self.id).minimum(:timestamp)
    GraphProtocol::Query.where(:query_set_id => self.id).update_all("\"offset\"=\"timestamp\"-#{first_query}")

  end

  private

    def set_uuid
      self.uuid ||= SecureRandom.uuid
    end
end
