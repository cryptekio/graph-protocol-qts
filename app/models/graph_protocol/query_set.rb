class GraphProtocol::QuerySet < ApplicationRecord
  has_many :queries, dependent: :destroy

  def load_data(args = {})

    puts "getting data from file"
    GraphProtocol::Query.copy_from_client [:subgraph, :query_id, :query, :variables, :timestamp, :created_at, :updated_at, :query_set_id] do |copy|
      File.foreach(args[:filename]) do |line|
        parsed_data = JSON.parse(line.chomp, symbolize_names: true).except(:block, :time)
        parsed_data[:timestamp] = DateTime.parse(parsed_data[:timestamp]).to_f
        time = Time.now
        copy << [parsed_data[:subgraph], parsed_data[:query_id], parsed_data[:query], parsed_data[:variables], parsed_data[:timestamp], time, time, self.id]
      end
    end

    puts "finding first query"
    first_query = GraphProtocol::Query.where(:query_set_id => self.id).minimum(:timestamp)

    puts "updating offsets"
    GraphProtocol::Query.where(:query_set_id => self.id).update_all("\"offset\"=\"timestamp\"-#{first_query}")

  end

end
