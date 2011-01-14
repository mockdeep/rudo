class List

  # prints tasks to the screen
  def print_tasks(task_limit=5, conditions={})
    puts '*' * 40
    conditions[:order] = [ :ordering.asc ]
    conditions[:limit] = task_limit
    quickness = conditions[:quick]
    Task.all(conditions).each_with_index do |task, index|
      puts "#{quickness.nil? ? (index+1).to_s + '. ': ''}#{task.to_s}"
    end
    puts '*' * 40
    unless quickness.nil?
      puts Colors.colored("#{Task.count(:quick => quickness)} #{quickness ? 'quick' : 'slow'} tasks remaining", :green)
    end
    puts Colors.colored("#{Task.count} tasks remaining", :green)
  end

  def all
    print_tasks(Task.count)
  end

  def quick(item=nil, quickness=true)
    if item
      begin
        number = Integer(item)
        task = Task.first(:ordering => number)
        task.quick = quickness
        task.save
        puts "task now set to quick -> #{task.title}"
      rescue
        add(item, quickness)
      end
    else
      print_tasks(Task.count, :quick => quickness)
    end
  end

  def slow(item=nil)
    quick(item, false)
  end

  def review
    count = Task.count
    counter = 0
    Task.all(:order => [ :ordering.asc ]).each do |task|
      counter += 1
      puts '-' * 40
      puts "(#{counter}/#{count}) #{task.to_s}"
      print "Done (D), or switch to #{task.quick ? 'slow (S)' : 'quick (Q)'}, hit enter to go to next task -> "
      $stdout.flush
      a = STDIN.gets.chomp
      if a.upcase == 'D'
        task.destroy
        sleep 1
      elsif a.upcase == 'Q'
        task.quick = true
        puts "changed to #{task.speed}"
        task.save
        sleep 1
      elsif a.upcase == 'S'
        task.quick = false
        puts "changed to #{task.speed}"
        task.save
        sleep 1
      end
    end
    puts '-' * 40
  end

  # adds a task to the end of the list
  def add(title=nil, quickness=false)
    raise 'you need to enter a title' unless title
    raise 'that task is already in the list' if Task.first(:title => title)
    Task.new(title, quickness).save
    puts "added task -> #{title}"
    print_tasks(5, :quick => quickness)
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
end
