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
      :file_path => params[:file_path], #s3 object key
      :status => 0
    }
    query_set = GraphProtocol::QuerySet.create(cfg)
    import = GraphProtocol::QlogImport.create(query_set: query_set,
                                              status: 0)
    import.initiate!

    render :json => query_set
  end

end
