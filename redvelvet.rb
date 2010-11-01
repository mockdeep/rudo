require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, 'sqlite://' + Dir.pwd + '/rv.db')

class Project
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String

  has n,                :tasks

  validates_presence_of :title
end

class Task
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :start_time, DateTime
  property :due_time,   DateTime

  validates_presence_of :title

  has n,                :notes
  belongs_to            :project, :required => false

  def initialize(attributes=nil)
    if attributes
      self.title = attributes[:title]
      self.start_time = attributes[:start_time]
    end
    self.start_time ||= Time.now
  end
end

class Note
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String

  validates_presence_of :title

  belongs_to            :task
end

DataMapper.auto_upgrade!
DataMapper.finalize
