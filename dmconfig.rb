require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite://' + Dir.pwd + '/redvelvet.db')
