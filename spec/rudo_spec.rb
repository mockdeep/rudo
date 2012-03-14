require 'rspec'
require 'colored'

require './lib/rudo.rb'

describe Rudo do
  describe '#print' do
    def stars
      '*' * 40
    end

    context 'when the color option is set to false' do
      before(:each) do
        file = File.open('spec/fixtures/empty.yml')
        File.stub(:open).and_return(file)
        @rudo = Rudo.new
      end

      it 'does not color output' do
        @rudo.should_receive(:puts).with(stars).twice
        @rudo.should_receive(:puts).with('0 tasks remaining')
        @rudo.print({:color => false})
      end
    end

    context 'when there are no tasks' do
      before(:each) do
        file =  File.open('spec/fixtures/empty.yml')
        File.stub(:open).and_return(file)
        @rudo = Rudo.new
        @rudo.stub(:puts).with(stars)
        @rudo.stub(:puts).with('0 tasks remaining'.green)
      end

      it 'prints two lines of stars' do
        @rudo.should_receive(:puts).with(stars).twice
        @rudo.print
      end

      it 'prints "0 tasks remaining" in green' do
        @rudo.should_receive(:puts).with('0 tasks remaining'.green)
        @rudo.print
      end
    end

    context 'when there are two tasks' do
      before(:each) do
        file =  File.open('spec/fixtures/twotasks.yml')
        File.stub(:open).and_return(file)
        @rudo = Rudo.new
        @rudo.stub(:puts).with(stars)
        @rudo.stub(:puts).with('1: clean gutters')
        @rudo.stub(:puts).with('2: do laundry')
        @rudo.stub(:puts).with('2 tasks remaining'.green)
      end

      it 'prints both tasks between rows of stars' do
        @rudo.should_receive(:puts).with(stars)
        @rudo.should_receive(:puts).with('1: clean gutters')
        @rudo.should_receive(:puts).with('2: do laundry')
        @rudo.should_receive(:puts).with(stars)
        @rudo.print
      end

      it 'prints the task count in green' do
        @rudo.should_receive(:puts).with('2 tasks remaining'.green)
        @rudo.print
      end
    end
  end

  describe '#add'
  describe '#remove'
  describe '#walk'
end
