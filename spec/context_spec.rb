require 'rvconfig'

describe Context do

  it 'requires a title' do
    Context.new.should_not be_valid
    Context.new.save!.should == false
    Context.new(:title => 'home').should be_valid
  end

  it 'has an order' do
    context1 = Context.new(:title => 'home')
    context1.save!
    context1.order.should == Context.count
    context2 = Context.new(:title => 'work')
    context2.save!
    context2.order.should == Context.count
  end

  it 'has many tasks' do
    context = Context.new
    context.should respond_to :tasks
    context.tasks.should == []
    task1 = Task.new
    task2 = Task.new
    context.tasks << task1
    context.tasks << task2
    context.save!
    context.tasks.should == [task1, task2]
  end

end
