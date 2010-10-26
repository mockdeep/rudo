require 'dmconfig.rb'

class Task
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
end

DataMapper.auto_upgrade!
DataMapper.finalize
