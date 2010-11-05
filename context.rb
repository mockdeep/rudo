class Context
  include DataMapper::Resource
  property :id,         Serial
  property :title,      String, :required => true
  property :order,      Integer

  has n,   :tasks, :through => Resource

  def initialize(params=nil)
    if params
      self.title = params[:title] if params[:title]
    end
    self.order = max_order + 1
  end

  def max_order
    puts 'max_order' + self.class.max(:order).to_s
    self.class.max(:order) || 0
  end

end
