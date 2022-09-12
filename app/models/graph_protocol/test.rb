class GraphProtocol::Test < ApplicationRecord
  belongs_to :query_set
  after_initialize :set_uuid
  TEST_STATUS = [:created,:stopped,:running,:finished,:failed]

  def status
    TEST_STATUS[read_attribute(:status)]
  end

  def status=(new_status)
    write_attribute(:status,TEST_STATUS.find_index(new_status))
  end


  private 

    def set_uuid
      self.uuid ||= SecureRandom.uuid
    end

end
