class List

  # prints tasks to the screen
  def self.print_tasks
    puts '*' * 40
    Task.all(:order => [ :ordering.asc ]).each do |task|
      break if task.ordering > 5
      puts task.to_s
    end
    puts '*' * 40
    puts "#{Task.count} tasks remaining"
  end

  def self.review
    Task.all(:order => [ :ordering.asc ]).each do |task|
      puts task.to_s
      puts 'Done/Next (D/N)'
      a = STDIN.gets.chomp
      if a.upcase == 'D'
        task.destroy
        puts 'task deleted'
      else
        puts 'moving along'
      end
    end
  end

  # adds a task to the end of the list
  def self.add(title=nil)
    raise 'you need to enter a title' unless title
    raise 'that task is already in the list' if Task.first(:title => title)
    Task.new(title).save
  end

  # removes a task from the list, the first one unless otherwise specified
  def self.done(identifier=nil)
    # if there aren't any items in the list...
    raise "there's nothing on your list!" if Task.all.empty?
    if identifier
      begin
        # Integer throws an error if 'identifier' contains anything that isn't numerical
        # begin-rescue anticipates this, and the rescue block is executed if an error is raised
        Task.first(:ordering => Integer(identifier)).destroy
      rescue
        # if 'identifier' wasn't a number, let's see if we have a task with that title instead
        task = Task.first(:title => identifier)
        task ? task.destroy : (raise "'done' should be followed by either the number or title of a task")
      end
    else
      Task.first(:ordering => 1).destroy
    end
  end

  # moves items from the beginning to the end of the list, one by default
  def self.walk(number=1)
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
  end

end
