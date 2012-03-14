require 'rspec'
require 'colored'
require 'spec_helper'

require './lib/rudo.rb'

describe Rudo do
  before :each do
    @empty_path = 'spec/fixtures/empty.yml'
    @two_path = 'spec/fixtures/twotasks.yml'
    @stars = '*' * 40
  end

  describe '#print' do
    context 'when the color option is set to false' do
      before(:each) do
        file = File.open(@empty_path)
        File.stub(:open).and_return(file)
        @rudo = Rudo.new
      end

      it 'does not color output' do
        @rudo.should_receive(:puts).with(@stars).twice
        @rudo.should_receive(:puts).with('0 tasks remaining')
        @rudo.print({:color => false})
      end
    end

    context 'when there are no tasks' do
      before(:each) do
        file =  File.open(@empty_path)
        File.stub(:open).and_return(file)
        @rudo = Rudo.new
        @rudo.stub(:puts).with(@stars)
        @rudo.stub(:puts).with('0 tasks remaining'.green)
      end

      it 'prints two lines of stars' do
        @rudo.should_receive(:puts).with(@stars).twice
        @rudo.print
      end

      it 'prints "0 tasks remaining" in green' do
        @rudo.should_receive(:puts).with('0 tasks remaining'.green)
        @rudo.print
      end
    end

    context 'when there are two tasks' do
      before(:each) do
        file =  File.open(@two_path)
        File.stub(:open).and_return(file)
        @rudo = Rudo.new
        @rudo.stub(:puts).with(@stars)
        @rudo.stub(:puts).with('1: clean gutters')
        @rudo.stub(:puts).with('2: do laundry')
        @rudo.stub(:puts).with('2 tasks remaining'.green)
      end

      it 'prints both tasks between rows of stars' do
        @rudo.should_receive(:puts).with(@stars)
        @rudo.should_receive(:puts).with('1: clean gutters')
        @rudo.should_receive(:puts).with('2: do laundry')
        @rudo.should_receive(:puts).with(@stars)
        @rudo.print
      end

      it 'prints the task count in green' do
        @rudo.should_receive(:puts).with('2 tasks remaining'.green)
        @rudo.print
      end
    end
  end

  describe '#add' do
    before :each do
      yaml = YAML.load(File.open(@two_path))
      YAML.stub(:load).and_return(yaml)
      @tasks = yaml
      @rudo = Rudo.new
    end

    context 'when position is nil' do
      it 'adds the task at the end of the list' do
        @tasks += ['blah']
        File.any_instance.should_receive(:write).with(YAML.dump(@tasks))
        @rudo.add('blah')
      end
    end

    context 'when position is given' do
      it 'adds the task at that position in the list' do
        @tasks = ['blah'] + @tasks
        File.any_instance.should_receive(:write).with(YAML.dump(@tasks))
        @rudo.add('blah', 0)
      end
    end
  end

  describe '#remove'
  describe '#walk'
end
