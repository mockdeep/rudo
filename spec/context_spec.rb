require 'rvconfig'

describe Context do

  it 'requires a title' do
    Context.new.should_not be_valid
    Context.new.save.should == false
    Context.new(:title => 'home').should be_valid
  end

  it 'has an ordering' do
    context1 = Context.new(:title => 'home')
    context1.save
    context1.ordering.should == Context.count
    context2 = Context.new(:title => 'work')
    context2.save
    context2.ordering.should == Context.count
    context2.ordering.should == context1.ordering + 1
  end

  it 'can move a context up in the ordering' do
    context1 = Context.new(:title => 'home')
    context1.save
    context2 = Context.new(:title => 'work')
    context2.save
    context2.move_up
    context1.reload
    context1.ordering.should == context2.ordering + 1
    context2.ordering.should == context1.ordering - 1
  end

  it 'can move a context down in the ordering' do
    context1 = Context.new(:title => 'home')
    context1.save
    context2 = Context.new(:title => 'work')
    context2.save
    context1.move_down
    context2.reload
    context1.ordering.should == context2.ordering + 1
    context2.ordering.should == context1.ordering - 1
  end

  it 'has many tasks' do
    context = Context.new
    context.should respond_to :tasks
    context.tasks.should == []
    task1 = Task.new
    task2 = Task.new
    context.tasks << task1
    context.tasks << task2
    context.save
    context.tasks.should == [task1, task2]
  end

end
