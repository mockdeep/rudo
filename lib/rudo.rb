require 'rubygems'
require 'colored'
require 'yaml'

class Rudo
  def initialize(options={})
    @file_path = File.expand_path(options.delete(:file_path) { '~/rudo.yml' })

    @tasks = YAML.load(File.open(@file_path))
  end

  def print(options={})
    colored = options.delete(:color) { true }
    puts stars
    @tasks.each_with_index do |task, index|
      puts "#{index + 1}: #{task}"
    end
    puts stars
    if colored
      puts "#{@tasks.length} tasks remaining".green
    else
      puts "#{@tasks.length} tasks remaining"
    end
  end

  def add(task, position=nil)
    position ||= @tasks.length
    @tasks.insert(position, task)
    write_tasks
  end

  def remove(position=1)
    if position.is_a?(String) && position.match(/^(\d+)x/)
      count = Integer($1)
      count.times { @tasks.shift }
    else
      position = position.to_i
      position -= 1 if position > 0
      @tasks.delete_at(position)
    end
    write_tasks
  end

  def walk(steps=1)
    steps.times do
      task = @tasks.shift
      @tasks << task
    end
    write_tasks
  end

private

  def stars
    "*" * 40
  end

  def write_tasks
    File.open(@file_path, 'w') do |file|
      file.write(YAML.dump(@tasks))
    end
    true
  end
end
