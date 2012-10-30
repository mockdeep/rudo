require 'spec_helper'

describe Rudo do
  let(:empty_path) { File.expand_path('./spec/fixtures/empty.yml') }
  let(:tasks_path) { File.expand_path('./spec/fixtures/tasks.yml') }
  let(:stars) { '*' * 40 }

  before(:each) do
    File.stub(:write)
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

  describe '#to_s' do
    context 'when there are no tasks' do
      let(:rudo) { Rudo.new(:file_path => empty_path) }

      it "returns two lines of stars and 0 tasks remaining" do
        expected = "#{stars}\n#{stars}\n#{"0 tasks remaining".green}"
        rudo.to_s.should == expected
      end
    end

    context 'when there are tasks' do
      let(:rudo) { Rudo.new(:file_path => tasks_path) }

      it "returns the task with the count in green" do
        expected = "#{stars}\n"
        expected << "1: clean gutters\n"
        expected << "2: do laundry\n"
        expected << "3: eat pizza\n"
        expected << "#{stars}\n"
        expected << "3 tasks remaining".green
        rudo.to_s.should == expected
      end
    end
  end
end
