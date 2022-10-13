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

    size = GraphProtocol::Util::S3::ObjectProcessor.get_object_size(key: query_set.file_path)
    GraphProtocol::Util::QuerySet::Importer.schedule_import_job(
                                                    query_set: query_set, object_size: size)

    render :json => query_set
  end

end
