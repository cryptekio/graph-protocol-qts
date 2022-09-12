class GraphProtocol::TestsController < ApplicationController

  def index
    response = GraphProtocol::Test.all
    render :json => response
  end

  def create
  end

  def show
  end

  def run
  end

end
