require 'redvelvet'
require 'time'

describe Task do
  before :each do
    @start_time = Time.parse('Wed Oct 27 18:53:46 -0700 2010')
    @valid_attributes = {
      :title => 'buy groceries',
      :start_time => @start_time
    }
  end

  it 'creates a new instance and assigns a title' do
    task = Task.new(:title => 'buy groceries')
    task.save!
    Task.first(:title => 'buy groceries').should_not be_nil
  end

  it 'does not allow blank titles' do
    task = Task.new.should_not be_valid
  end

  it 'has notes' do
    Task.new.should respond_to :notes
  end

  it 'has a project' do
    task = Task.new
    task.should respond_to :project
    task.project.should be_nil
    project = Project.new
    task.project = project
    task.project.should_not be_nil
  end

  it 'defaults start time to now' do
    Task.new.start_time.strftime('%c').should == Time.now.strftime('%c')
  end

  it 'sets the start time' do
    Task.new(@valid_attributes).start_time.strftime('%c').should == @start_time.strftime("%c")
  end

  it 'defaults the due time to nil' do
    Task.new(@valid_attributes).due_time.should == nil
  end
end
