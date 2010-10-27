require 'dmconfig.rb'

class Project
  include DataMapper::Resource
  property :id,         Serial
  property :name,       String
end

DataMapper.auto_upgrade!
DataMapper.finalize
