class GraphProtocol::QlogImport < ApplicationRecord
  belongs_to :query_set

  IMPORT_STATUS = [:created,:running,:waiting,:finished,:failed]

  def status
    IMPORT_STATUS[read_attribute(:status)]
  end

  def status=(new_status)
    write_attribute(:status,IMPORT_STATUS.find_index(new_status))
    save
  end

end
