class GraphProtocol::TestsController < ApplicationController

  def index
    response = []

    GraphProtocol::Test.all.each do |test|
      response << test.json_print
    end

    render :json => response
  end

  def create
    response = GraphProtocol::Test.create(test_params)

    print_json(response)
  end

  def show
    response = GraphProtocol::Test.find_by(id: test_id)

    print_json(response)
  end

  def run
    test = GraphProtocol::Test.find_by(id: test_id)
    instance = test.instances.create

    instance.run

    print_json(instance)
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

  def print_error(msg = {})
    render :json => msg
  end

  def print_json(test)
    if test 
      render :json => test.json_print
    else
      print_error(error: "Test definition not found.")
    end
  end

end
