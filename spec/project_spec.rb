require 'project'

describe Project do
  it 'creates a new instance and assigns a name' do
    project = Project.new(:name => 'buy groceries')
    project.save!
    Project.first(:name => 'buy groceries').should_not be_nil
  end
end
