require 'task'

describe Task do
  it 'creates a new instance and assigns a name' do
    task = Task.new
    task.name = 'buy groceries'
  end
end
