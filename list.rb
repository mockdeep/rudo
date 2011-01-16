class List
  include DataMapper::Resource
  property :id,           Serial
  property :print_count,  Integer
  property :last_tag,     String

  def initialize(print_count=5)
    self.print_count = print_count
  end

  # prints tasks to the screen
  def print_tasks(tasks=nil)
    puts '*' * 40
    if tasks.nil? and self.last_tag
      tasks = Tag.first(:title => self.last_tag, :limit => self.print_count).tasks
    elsif tasks.nil?
      self.print_count ||= Task.count
      tasks = Task.all(:limit => self.print_count, :order => [ :ordering.asc ])
    end
    tasks.all.each_with_index do |task, index|
      puts "#{(index+1).to_s + '. '}#{task.to_s}"
    end
    puts '*' * 40
    unless self.last_tag.nil?
      puts Colors.colored("#{Tag.first(:title => self.last_tag).tasks.count} #{self.last_tag} tasks remaining", :green)
    end
    puts Colors.colored("#{Task.count} tasks remaining", :green)
  end

  def all
    self.print_count = Task.count
    print_tasks
  end

  def set_count(count)
    if count == 'all'
      self.print_count = nil
      self.save
    elsif count.match(/^(\d+)$/)
      self.print_count = count
      self.save
    else
      raise "invalid input, try 'all' or an integer"
    end
    print_tasks
  end

  def review
    count = Task.count
    counter = 0
    Task.all(:order => [ :ordering.asc ]).each do |task|
      counter += 1
      puts '-' * 40
      puts "(#{counter}/#{count}) #{task.to_s}"
      print "Done (D) or hit enter to go to next task -> "
      $stdout.flush
      a = STDIN.gets.chomp
      if a.upcase == 'D'
        task.destroy
        sleep 1
      end
    end
    puts '-' * 40
  end

  # adds a task to the end of the list
  def add(title=nil)
    raise 'you need to enter a title' unless title
    if Task.first(:title => title)
      puts "task already in list -> #{title}"
    else
      Task.new(title).save
      puts "added task -> #{title}"
    end
    print_tasks
  end

  def tag(identifier=nil)
    if identifier.nil?
      puts 'listing of tags'
      Tag.each do |tag|
        puts tag.title
      end
    elsif identifier.match(/^(\d+)$/)
      task = Task.all(:order => [ :ordering.asc ])[Integer(identifier)-1]
      puts "Enter tag name for task -> #{task.title}"
      print "-> "
      $stdout.flush
      a = STDIN.gets.chomp
      if a == ''
        raise 'you need to enter a tag name'
      else
        t = Tag.first(:title => a) || Tag.new(title)
        task.tags << t
        task.save
        puts "Tag added -> #{t.title}"
      end
    elsif identifier == ''
      puts "items without tags"
      Task.all.each do |task|
        puts task if task.tags.empty?
      end
    else
      puts "listing tasks associated with tag -> #{identifier}"
      Task.all.each do |task|
        puts task if task.tags.collect{|tasktag| tasktag.title}.include? identifier
      end
    end
  end

  # removes a task from the list, the first one unless otherwise specified
  def done(identifier=nil)
    # if there aren't any items in the list...
    raise "there's nothing on your list!" if Task.all.empty?
    if identifier and identifier.match(/(\d+)x/)
      count = Integer($1)
      count.times do
        Task.first.destroy
      end
    elsif identifier
      begin
        # Integer throws an error if 'identifier' contains anything that isn't numerical
        # begin-rescue anticipates this, and the rescue block is executed if an error is raised
        Task.all(:order => [ :ordering.asc ])[Integer(identifier)-1].destroy
      rescue
        # if 'identifier' wasn't a number, let's see if we have a task with that title instead
        task = Task.first(:title => identifier)
        task ? task.destroy : (raise "'done' should be followed by either the number or title of a task")
      end
    else
      Task.first(:order => :ordering).destroy
    end
    print_tasks
  end

  # moves items from the beginning to the end of the list, one by default
  def walk(number=1)
    # if there aren't any items in the list...
    raise "you're walking in place" if Task.all.empty?
    begin
      # like in 'done' we are checking to see that we actually have a number
      number = Integer(number)
    rescue
      raise 'walk should be followed by an integer'
    end
    # if they input a number greater than or equal to the number of tasks
    raise "I don't like walking in circles" if number.abs >= Task.count
    invert_set = []
    Task.all(:order => [:ordering.asc]).each do |task|
      # decrease the ordering of all the tasks by number
      task.ordering -= number
      invert_set << task if task.ordering <= 0
      task.save
    end

    invert_set.each do |task|
      # move the tasks with an ordering <= 0 to the end of the list
      ordering = [Task.max(:ordering), 0].max
      task.ordering =  ordering + 1
      task.save
    end

    while Task.min(:ordering) > 1 do
      # fill in the ordering gaps at the beginning of the list, in case user inputs a negative number
      task = Task.first(:ordering => Task.max(:ordering))
      task.ordering = Task.min(:ordering) - 1
      task.save
    end

    print_tasks
  end

  def change(number=nil)
    raise 'change should be followed by the number of a task' unless number
    begin
      number = Integer(number)
    rescue
      raise 'change should be followed by the number of a task'
    end
    raise "you don't have that many tasks" if number > Task.count
    task = Task.first(:ordering => number)
    puts "Enter new title for task -> #{task.title}"
    print "-> "
    $stdout.flush
    a = STDIN.gets.chomp
    if a == ''
      raise 'you need to enter a task name'
    else
      task.title = a
      task.save
      puts "Title changed to -> #{task.title}"
    end
  end

  def test
    Task.all(:order => [ :ordering.asc ])[9].to_a
    Task.first(:offset => 9, :order => [ :ordering.asc ]).to_a
    Task.all(:limit => 10, :offset => 9, :order => [ :ordering.asc ]).to_a
  end
end
