class GraphProtocol::TestInstance < ApplicationRecord
  belongs_to :test

  TEST_STATUS = [:created,:stopped,:running,:finished,:failed]

  def get_status
    TEST_STATUS[read_attribute(:status)]
  end

  def set_status=(new_status)
    update_attribute(:status,TEST_STATUS.find_index(new_status))
  end

  def run
    GraphProtocol::Util::Qlog::RequestLoader.execute(self)
  end

end
