require 'task'

describe Task do
  it 'creates a new instance and assigns a name' do
    task = Task.new(:name => 'buy groceries')
    task.save!
    Task.first(:name => 'buy groceries').should_not be_nil
  end
end
