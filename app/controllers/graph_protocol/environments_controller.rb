class GraphProtocol::EnvironmentsController < ApplicationController

  def index
    response = []

    GraphProtocol::Environment.all.each do |env|
      response << env.json_print
    end

    render :json => response
  end

  def create
    response = GraphProtocol::Environment.create(env_params)

    print_json(response)
  end

  def show
    response = GraphProtocol::Environment.find_by(env_params)

    print_json(response)
  end


  private

  def env_params
    params.require(:environment).permit(:name,
                                        :gateway_url,
                                        api_keys: [] )
  end


  def print_error(msg = {})
    render :json => msg
  end

  def print_json(test)
    if test.id
      render :json => test.json_print
    else
      print_error(error: "Environment definition not found.")
    end
  end

end
