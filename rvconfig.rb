require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'dm-aggregates'
require 'task'
require 'project'
require 'note'
require 'context'
require 'project_manager'

db_name = nil
if caller.last.include? 'rspec'
  # use the test database
  db_name = 'rvtest.sqlite'
  File.delete(db_name) if File.exist?(db_name)
else
  # use the regular database
  db_name = 'rv.sqlite'
end

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite://' + Dir.pwd + '/' + db_name)

DataMapper.finalize
DataMapper.auto_upgrade!
