class Rudo
  class List
    attr_accessor :tasks

    def initialize
      self.file_path = File.expand_path('~/rudo.yml')
      self.tasks = YAML.load(File.read(file_path))
    end

    def length
      tasks.length
    end

    def add(task)
      tasks << task
      write_tasks
    end

    def prepend(task)
      tasks.unshift(task)
      write_tasks
    end

    def remove(arg=0)
      if arg.to_s =~ /^(\d+)x$/
        $1.to_i.times { tasks.shift }
      else
        tasks.delete_at(arg.to_i)
      end
      write_tasks
    end

    def walk(count=1)
      count.to_i.times { tasks << tasks.shift }
      write_tasks
    end

    def last
      tasks.last
    end

    def first
      tasks.first
    end

    def to_s
      string = "#{stars}\n"
      tasks.each_with_index do |task, index|
        string << "#{index + 1}: #{task}\n"
      end

      string << "#{stars}\n"
      string << "#{tasks.length} tasks remaining".green
    end

    private

    attr_accessor :file_path

    def stars
      "*" * 40
    end

    def write_tasks
      File.write(file_path, tasks.to_yaml)
    end
  end
end
