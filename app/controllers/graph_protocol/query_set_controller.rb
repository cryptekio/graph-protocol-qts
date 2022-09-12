class GraphProtocol::QuerySetController < ApplicationController
  def index
    response = GraphProtocol::QuerySet.all
    render :json => response
  end
end
