require 'task'

describe Task do
  it 'creates a new instance and assigns a title' do
    task = Task.new(:title => 'buy groceries')
    task.save!
    Task.first(:title => 'buy groceries').should_not be_nil
  end

  it 'does not allow blank titles' do
    task = Task.new.should_not be_valid
  end
end
