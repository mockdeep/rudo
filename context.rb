class Context
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String, :required => true
  property :ordering,      Integer

  has n,   :tasks, :through => Resource

  def initialize(params=nil)
    if params
      self.title = params[:title] if params[:title]
    end
    self.ordering = max_ordering + 1
  end

  def max_ordering
    self.class.max(:ordering) || 0
  end

  def move_up
    temp = self.class.first(:ordering => self.ordering - 1)
    temp.ordering += 1
    temp.save
    self.ordering -= 1
    self.save
  end

end
