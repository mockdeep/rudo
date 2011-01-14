class Task
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :ordering,   Integer
  property :quick,      Boolean, :default => false

  def initialize(title, quickness)
    self.title = title
    self.quick = quickness
    self.ordering = (self.class.max(:ordering) || 0) + 1
  end

  def speed
    self.quick ? 'quick' : 'slow'
  end

  def to_s
    color = (quick ? :blue : :yellow)
    Colors.colored("#{self.title}", color)
  end

  before :destroy do |task|
    # when we delete a task we fill in the gap in ordering it left behind
    # in the future we may decide to not actually destroy the task, but to just have it flagged 'done'
    puts "deleting task -> #{self.title}"
  end
end
