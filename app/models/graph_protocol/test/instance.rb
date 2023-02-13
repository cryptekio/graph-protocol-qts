class GraphProtocol::Test::Instance < ApplicationRecord
  belongs_to :test
  before_validation :verify_query_set_status, on: :create
  before_validation :set_default_values, on: :create
  after_commit :run, on: :create

  TEST_STATUS = [:created,:stopped,:running,:finished,:failed,:deleted]

  def verify_query_set_status
    raise GraphProtocol::Util::QuerySet::NotReady unless query_set.get_status == :ready
  end

  def set_default_values
    self.set_status :created if self.status.blank?
  end

  def json_print
    self.test.slice(:query_set_id,
                    :subgraphs,
                    :chunk_size,
                    :query_limit,
                    :speed_factor,
                    :loop_queries,
                    :sleep_enabled).merge({:status => get_status})
  end

  def config
    { query_set_id: query_set.id,
      subgraphs: subgraphs,
      chunk_size: chunk_size,
      speed_factor: speed_factor,
      loop_queries: loop_queries,
      query_limit: query_limit
    }
  end

  def api_key
    test.environment.api_key
  end

  def gateway_url
    test.environment.gateway_url
  end

  def loop?
    test.loop?
  end

  def speed_factor
    test.speed_factor
  end

  def sleep_enabled
    test.sleep_enabled
  end

  def subgraphs
    test.subgraphs
  end

  def query_set
    test.query_set
  end

  def query_limit
    test.query_limit
  end

  def chunk_size
    test.chunk_size
  end

  def workers
    test.workers
  end

  def get_status
    TEST_STATUS[read_attribute(:status)]
  end

  def set_status(new_status)
    update_attribute(:status,TEST_STATUS.find_index(new_status))
  end

  def add_jid(jid)
    jobs << jid
    save
  end

  def set_master_jid(jid)
    update_attribute(:master_job,jid)
  end

  def set_start_time(start_time)
    update_attribute(:start_time, start_time)
  end

  def run
    GraphProtocol::TestInstanceMasterJob.perform_later(id: self.id)
  end

  def cancel
    GraphProtocol::Util::Qlog::TestMaster.cancel!(self)
  end


end
