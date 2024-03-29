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

  def start_all
    GraphProtocol::Test.all.each do |test|
      instance = test.instances.create
    end
  end

  def stop_all
    GraphProtocol::Test.all.each do |test|
      test.instances.each do |instance|
        instance.cancel
      end
    end
  end

  def stop_all_instances
    test = GraphProtocol::Test.find_by(id: test_id)
    test.instances.each do |instance|
      instance.cancel
    end
  end

  def show_instance
    test = GraphProtocol::Test.find_by(id: test_id)
    instance = test.instances.find_by(id: instance_id)

    print_json(instance)
  end

  def cancel_instance
    test = GraphProtocol::Test.find_by(id: test_id)
    instance = test.instances.find_by(id: instance_id)
    instance.cancel
    
    print_json(instance)
  end


  def run
    test = GraphProtocol::Test.find_by(id: test_id)

    unless test.nil?
      begin
        instance = test.instances.create
      rescue GraphProtocol::Util::QuerySet::NotReady
        print_error(error: "Cannot run test: query set is not ready.")
        return
      end
    end

    print_json(instance)
  end

  def delete
    test = GraphProtocol::Test.find_by(id: test_id)

    unless test.nil?
      test.instances.each do |instance|
        if instance.get_status == :running
          print_error(error: "Cannot delete test #{test_id}: instance of it is currently running.")
          return
        end
      end
      test.destroy
    end
    print_json(test)
  end

  private

  def test_id
    params.require(:id)
  end

  def instance_id
    params.require(:iid)
  end

  def test_params
    params.require(:test).permit(:query_set_id,
                                 :speed_factor,
                                 :loop_queries,
                                 :chunk_size,
                                 :query_limit,
                                 :environment_id,
                                 subgraphs: [])
  end

  def print_error(msg = {})
    render :json => msg
  end

  def print_json(test)
    if test.id
      render :json => test.json_print
    else
      print_error(error: "Test definition not found.")
    end
  end

end
