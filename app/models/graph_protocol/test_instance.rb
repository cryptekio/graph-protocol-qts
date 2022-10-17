class GraphProtocol::TestInstance < ApplicationRecord
  belongs_to :test

  TEST_STATUS = [:created,:stopped,:running,:finished,:failed]

  def status
    TEST_STATUS[read_attribute(:status)]
  end

  def status=(new_status)
    write_attribute(:status,TEST_STATUS.find_index(new_status))
    save
  end

end
