class Task
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :ordering,      Integer

  def initialize(title)
    self.title = title
    self.ordering = (self.class.max(:ordering) || 0) + 1
  end

  def to_s
    self.ordering.to_s + '. ' + self.title
  end

  before :destroy do |task|
    # when we delete a task we fill in the gap in ordering it left behind
    # in the future we may decide to not actually destroy the task, but to just have it flagged 'done'
    self.class.all(:ordering.gt => task.ordering).each do |task2|
      task2.ordering -= 1
      task2.save
    end
  end

end
