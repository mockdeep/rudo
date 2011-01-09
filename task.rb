require 'colors'

class Task
  include DataMapper::Resource
  include Colors
  property :id,         Serial
  property :title,      String
  property :ordering,   Integer
  property :quick,      Boolean, :default => false

  def initialize(title)
    self.title = title
    self.ordering = (self.class.max(:ordering) || 0) + 1
  end

  def speed
    self.quick ? 'quick' : 'slow'
  end

  def to_s
    color = (quick ? :blue : :yellow)
    self.ordering.to_s + ". \e[#{COLORS[color]}m#{self.title}\e[0m"
  end

  before :destroy do |task|
    # when we delete a task we fill in the gap in ordering it left behind
    # in the future we may decide to not actually destroy the task, but to just have it flagged 'done'
    puts "deleting task -> #{self.title}"
    self.class.all(:ordering.gt => task.ordering).each do |task2|
      task2.ordering -= 1
      task2.save
    end
  end

end
