require 'redvelvet'

describe Project do
  it 'creates a new instance and assigns a title' do
    project = Project.new(:title => 'buy groceries')
    project.save!
    Project.first(:title => 'buy groceries').should_not be_nil
  end

  it 'requires a title' do
    Project.new.should_not be_valid
  end

  it 'has many tasks' do
    Project.new.should respond_to :tasks
  end
end
