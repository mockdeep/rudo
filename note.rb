require 'dmconfig.rb'

class Note
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String

  validates_presence_of :title

  belongs_to            :task
end

DataMapper.auto_upgrade!
DataMapper.finalize
