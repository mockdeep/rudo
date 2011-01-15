class List
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
      print_tasks(:quick => quickness)
    end
  end

  def slow(item=nil)
    quick(item, false)
  end
end
