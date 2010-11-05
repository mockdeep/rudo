class Task
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :start_time, DateTime
  property :due_time,   DateTime

  validates_presence_of :title

  has n,                :notes
  has n,                :contexts, :through => Resource
  belongs_to            :project, :required => false

  def initialize(attributes=nil)
    if attributes
      self.title = attributes[:title]
      self.start_time = attributes[:start_time]
    end
    self.start_time ||= Time.now
  end
end
