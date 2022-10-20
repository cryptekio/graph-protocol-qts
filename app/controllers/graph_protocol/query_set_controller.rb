class GraphProtocol::QuerySetController < ApplicationController

  def index
    response = GraphProtocol::QuerySet.all
    render :json => response
  end

  def show
    set = GraphProtocol::QuerySet.find_by(id: query_set_id)

    render :json => set
  end

  def create
    query_set = GraphProtocol::QuerySet.create(query_set_params)

    render :json => query_set
  end

  private

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

end
