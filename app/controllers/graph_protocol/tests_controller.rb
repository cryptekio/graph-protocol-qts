class GraphProtocol::TestsController < ApplicationController

  def index
    response = GraphProtocol::Test.all
    render :json => response
  end

  def create
    response = GraphProtocol::Test.create(test_params)
    render :json => response 
  end

  def show
    response = GraphProtocol::Test.find_by(id: test_id)
    render :json => response
  end

  def run
    test = GraphProtocol::Test.find_by(id: test_id)
    instance = test.test_instances.create

    instance.run

    render :json => instance
  end

  private

  def test_id
    params.require(:id)
  end

  def test_params
    params.require(:test).permit(:query_set_id,
                                 :subgraphs,
                                 :query_limit)
  end

end
