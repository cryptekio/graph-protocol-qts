class GraphProtocol::Test::Instance < ApplicationRecord
  belongs_to :test

  TEST_STATUS = [:created,:stopped,:running,:finished,:failed]

  def json_print
    self.test.slice(:query_set_id,
                    :subgraphs,
                    :chunk_size,
                    :query_limit,
                    :sleep_enabled).merge({:status => get_status})
  end

  def config
    { query_set_id: query_set.id,
      subgraphs: subgraphs,
      chunk_size: chunk_size,
      query_limit: query_limit
    }
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

  def run
    GraphProtocol::Util::Qlog::RequestLoader.execute(self)
  end
end
