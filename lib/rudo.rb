require 'rubygems'
require 'colored'
require 'yaml'
require 'rudo/list'

class Rudo
  def initialize(options={})
    @file_path = File.expand_path(options.delete(:file_path) { '~/rudo.yml' })

    @tasks = YAML.load(File.read(@file_path))
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
    steps.times { @tasks << @tasks.shift }
    write_tasks
  end

  def to_s
    string = "#{stars}\n"

    @tasks.each_with_index do |task, index|
      string << "#{index + 1}: #{task}\n"
    end

    string << "#{stars}\n"
    string << "#{@tasks.length} tasks remaining".green
  end

private

  def stars
    "*" * 40
  end

  def write_tasks
    File.write(@file_path, YAML.dump(@tasks))
  end
end
