require 'spec_helper'

describe Rudo do
  let(:empty_path) { File.expand_path('./spec/fixtures/empty.yml') }
  let(:tasks_path) { File.expand_path('./spec/fixtures/tasks.yml') }
  let(:stars) { '*' * 40 }

  before(:each) do
    File.stub(:write)
  end

  describe '#print' do
    context 'when the color option is set to false' do
      let(:rudo) { Rudo.new(:file_path => empty_path) }

      it 'does not color output' do
        rudo.should_receive(:puts).with(stars).twice
        rudo.should_receive(:puts).with('0 tasks remaining')
        rudo.print({:color => false})
      end
    end

    context 'when there are no tasks' do
      let(:rudo) { Rudo.new(:file_path => empty_path) }

      before(:each) do
        rudo.stub(:puts).with(stars)
        rudo.stub(:puts).with('0 tasks remaining'.green)
      end

      it 'prints two lines of stars' do
        rudo.should_receive(:puts).with(stars).twice
        rudo.print
      end

      it 'prints "0 tasks remaining" in green' do
        rudo.should_receive(:puts).with('0 tasks remaining'.green)
        rudo.print
      end
    end

    context 'when there are tasks' do
      let(:rudo) { Rudo.new(:file_path => tasks_path) }

      before(:each) do
        rudo.stub(:puts).with(stars)
        rudo.stub(:puts).with('1: clean gutters')
        rudo.stub(:puts).with('2: do laundry')
        rudo.stub(:puts).with('3: eat pizza')
        rudo.stub(:puts).with('3 tasks remaining'.green)
      end

      it 'prints tasks between rows of stars' do
        rudo.should_receive(:puts).with(stars)
        rudo.should_receive(:puts).with('1: clean gutters')
        rudo.should_receive(:puts).with('2: do laundry')
        rudo.should_receive(:puts).with('3: eat pizza')
        rudo.should_receive(:puts).with(stars)
        rudo.print
      end

      it 'prints the task count in green' do
        rudo.should_receive(:puts).with('3 tasks remaining'.green)
        rudo.print
      end
    end
  end

  describe '#add' do
    let(:tasks) { YAML.load(File.read(tasks_path)) }
    let(:rudo) { Rudo.new(:file_path => tasks_path) }

    context 'when position is nil' do
      it 'adds the task at the end of the list' do
        expected_tasks = tasks + ['blah']
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.add('blah')
      end
    end

    context 'when position is given' do
      it 'adds the task at that position in the list' do
        expected_tasks = ['blah'] + tasks
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.add('blah', 0)
      end
    end
  end

  describe '#remove' do
    let(:tasks) { YAML.load(File.read(tasks_path)) }
    let(:rudo) { Rudo.new(:file_path => tasks_path) }

    context 'when position is some number followed by an "x"' do
      it 'removes the first n items' do
        expected_tasks = tasks[2..-1]
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.remove('2x')
      end
    end

    context 'when the position is a number' do
      it 'removes the item specified' do
        expected_tasks = [ tasks.first, tasks.last ]
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.remove('2')
      end
    end

    context 'when the position is trash text' do
      it 'removes the first item in the list' do
        expected_tasks = tasks[1..-1]
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.remove('trash')
      end
    end

    context 'when the position is nil' do
      it 'removes the first item in the list' do
        expected_tasks = tasks[1..-1]
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.remove(nil)
      end
    end

    context 'when the position is not given' do
      it 'removes the first item in the list' do
        expected_tasks = tasks[1..-1]
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.remove
      end
    end
  end

  describe '#walk' do
    let(:tasks) { YAML.load(File.read(tasks_path)) }
    let(:rudo) { Rudo.new(:file_path => tasks_path) }

    context 'when no argument is given' do
      it 'moves the first item in the list to the end' do
        expected_tasks = tasks[1..-1] + tasks[0, 1]
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.walk
      end
    end

    context 'when a number is given' do
      it 'moves n items to the end of the list' do
        expected_tasks = tasks[2..-1] + tasks[0, 2]
        File.should_receive(:write).with(tasks_path, YAML.dump(expected_tasks))
        rudo.walk(2)
      end
    end
  end
end
