class List

  # prints tasks to the screen
  def print_tasks
    puts '*' * 40
    Task.all(:order => [ :ordering.asc ]).each do |task|
      break if task.ordering > 5
      puts task.to_s
    end
    puts '*' * 40
    puts "#{Task.count} tasks remaining"
  end

  def qad(title=nil)
    task = Task.new(title)
    task.quick = true
    task.save
    puts "added quick task -> #{task.title}"
  end

  def quick
    puts '*' * 40
    count = 0
    Task.all(:quick => true, :order => [ :ordering.asc ]).each do |task|
      count += 1
      puts task.to_s
    end
    puts '*' * 40
    puts "#{count} quick tasks remaining"
    puts "#{Task.count} tasks remaining"
  end

  def review
    count = Task.count
    counter = 0
    Task.all(:order => [ :ordering.asc ]).each do |task|
      counter += 1
      puts '-' * 40
      puts "(#{counter}/#{count}) #{(task.quick ? 'quick' : 'slow')} -> #{task.title}"
      print 'Done or change speed (D/S), hit enter to go to next task -> '
      $stdout.flush
      a = STDIN.gets.chomp
      if a.upcase == 'D'
        task.destroy
        sleep 1
      elsif a.upcase == 'S'
        task.quick = !task.quick
        puts "changed to #{task.speed}"
        task.save
        sleep 1
      end
    end
    puts '-' * 40
  end

  # adds a task to the end of the list
  def add(title=nil)
    raise 'you need to enter a title' unless title
    raise 'that task is already in the list' if Task.first(:title => title)
    Task.new(title).save
    puts "added task -> #{title}"
  end

  # removes a task from the list, the first one unless otherwise specified
  def done(identifier=nil)
    # if there aren't any items in the list...
    raise "there's nothing on your list!" if Task.all.empty?
    if identifier and identifier.match(/(\d+)x/)
      count = Integer($1)
      count.times do
        Task.first(:ordering => 1).destroy
      end
    elsif identifier
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
end
