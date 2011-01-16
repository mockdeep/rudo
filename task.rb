class Task
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :ordering,   Integer

  has n, :taggings
  has n, :tags, :through => :taggings

  def initialize(title)
    self.title = title
    self.ordering = (self.class.max(:ordering) || 0) + 1
  end

  def to_s
    tag = self.tags.first
    color = ( tag ? tag.color : :white )
    Colors.colored("#{self.title}", color )
  end

  before :destroy do |task|
    # when we delete a task we fill in the gap in ordering it left behind
    # in the future we may decide to not actually destroy the task, but to just have it flagged 'done'
    puts "deleting task -> #{self.title}"
  end
end

class Tag
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String
  property :color,      String
  has n,   :taggings
  has n,   :tasks, :through => :taggings

  def initialize(title)
    self.title = title
    self.color = :white
  end
end

class Tagging
  include DataMapper::Resource
  belongs_to :task,   :key => true
  belongs_to :tag,    :key => true
end
