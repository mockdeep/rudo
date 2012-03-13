require 'rspec'
require 'colored'

require './lib/rudo.rb'

describe Rudo do

  it "should pass a dumb test" do
    r = Rudo.new
    r.class.should == Rudo
  end

  describe "#print" do

    def stars
      '*' * 40
    end

    context "when the color option is set to false" do

      before(:each) do
        file =  File.open('spec/fixtures/empty.yml')
        File.stub(:open).and_return(file)
      end

      it "doesn't color highlighted output" do
        r = Rudo.new
        r.should_receive(:puts).with(stars).twice
        r.should_receive(:puts).with('0 tasks remaining')
        r.print({:color => false})
      end
    end

    context "when there are no tasks" do

      before(:each) do
        file =  File.open('spec/fixtures/empty.yml')
        File.stub(:open).and_return(file)
      end

      it "prints two lines of stars and green text '0 tasks remaining'" do
        r = Rudo.new
        r.should_receive(:puts).with(stars).twice
        r.should_receive(:puts).with('0 tasks remaining'.green)
        r.print
      end
    end

    context "when there are two tasks" do

      before(:each) do
        file =  File.open('spec/fixtures/twotasks.yml')
        File.stub(:open).and_return(file)
      end

      it "prints both tasks" do
        r = Rudo.new
        r.should_receive(:puts).with(stars)
        r.should_receive(:puts).with('1: clean gutters')
        r.should_receive(:puts).with('2: do laundry')
        r.should_receive(:puts).with(stars)
        r.should_receive(:puts).with('2 tasks remaining'.green)
        r.print
      end
    end

  end

end

