class GraphProtocol::TestsController < ApplicationController

  def index
    response = GraphProtocol::Test.all
    render :json => response
  end

  def create
    cfg = { query_set_id: params[:query_set_id],
            subgraphs: params[:subgraphs] || [],
            query_limit: params[:query_limit],
            workers: params[:workers] || 50 }
    response = GraphProtocol::Test.create(cfg)
    render :json => response 
  end

  def show
    response = GraphProtocol::Test.find_by(id: params[:id])
    render :json => response
  end

  def run
    test = GraphProtocol::Test.find_by(id: params[:id])
    instance = test.test_instances.create

    instance.run

    render :json => instance
  end

end
