class GraphProtocol::QuerySetController < ApplicationController

  def index
    result = []

    GraphProtocol::QuerySet.all.each do |query_set| 
      result << query_set.json_print
    end

    render :json => result 
  end

  def show
    query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)
    
    print_json(query_set)
  end

  def reimport
    query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)
    query_set.import_dataset unless query_set.nil?

    print_json(query_set)
  end

  def create
    query_set = GraphProtocol::QuerySet.create(query_set_params)

    print_json(query_set) 
  end

  def delete
    query_set = GraphProtocol::QuerySet.find_by(id: query_set_id)

    unless query_set.nil?

      if used_by_tests?(query_set)
        print_error(error: "Cannot delete query set #{query_set.id}: it is currently part of a test definition")
        return
      end

      query_set.set_status :deleted
      GraphProtocol::DeleteQuerySetJob.perform_later(query_set_id: query_set)
    end

    print_json(query_set)
  end

  private

  def used_by_tests?(query_set)
    GraphProtocol::Test.where(query_set_id: query_set.id).count > 0
  end

  def query_set_id
    params.require(:id)
  end

  def query_set_params
    params.require(:query_set).permit(:name,
                                      :description,
                                      :query_set_type,
                                      :import_type,
                                      :file_path)
  end

  def print_error(msg = {})
    render :json => msg
  end

  def print_json(query_set)
    if query_set
      render :json => query_set.json_print
    else
      print_error(error: "Query set not found.")
    end
  end

end
