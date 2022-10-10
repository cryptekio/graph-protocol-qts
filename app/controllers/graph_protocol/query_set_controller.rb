class GraphProtocol::QuerySetController < ApplicationController
  def index
    response = GraphProtocol::QuerySet.all
    render :json => response
  end

  def create
    cfg = {
      :name => params[:name] || nil,
      :description => params[:description] || nil,
      :query_set_type => params[:query_set_type], #qlog
      :import_type => params[:import_type], # s3
      :file_path => params[:file_path] #s3 object key
    }
    query_set = GraphProtocol::QuerySet.new(cfg)
    query_set.status = :created
    query_set.save

    GraphProtocol::QuerySetImportJob.perform_later(:query_set_id => query_set.id)

    render :json => query_set
  end

end
