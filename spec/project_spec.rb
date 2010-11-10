require 'rvconfig'

describe Project do
  it 'creates a new instance and assigns a title' do
    project = Project.new(:title => 'buy groceries')
    project.save
    Project.first(:title => 'buy groceries').should_not be_nil
  end

  it 'requires a title' do
    Project.new.should_not be_valid
  end

  it 'has many tasks' do
    project = Project.new
    project.should respond_to :tasks
    project.tasks.should == []
    task1 = Task.new
    task2 = Task.new
    project.tasks << task1
    project.tasks << task2
    project.save
    project.tasks.should == [task1, task2]
  end

end
