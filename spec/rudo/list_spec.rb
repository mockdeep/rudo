require 'spec_helper'

describe Rudo::List do
  let(:tasks) { ["buy groceries", "wax the dog", "feed the elephant"] }
  let(:file_path) { File.expand_path('~/rudo.yml') }
  let(:yaml) { tasks.to_yaml }
  let(:list) { Rudo::List.new }

  before(:each) do
    File.stub(:read).and_return(yaml)
    File.stub(:write)
  end

  describe '#add' do
    it "adds the task to the end of the list" do
      expect {
        list.add("do laundry")
      }.to change(list, :length).by(1)
      list.last.should eq "do laundry"
    end

    it "writes the tasks to a file" do
      new_tasks = tasks + ["do laundry"]
      File.should_receive(:write).with(file_path, new_tasks.to_yaml)
      list.add("do laundry")
    end
  end

  describe '#prepend' do
    it "adds the task to the beginning of the list" do
      expect {
        list.prepend("do laundry")
      }.to change(list, :length).by(1)
      list.first.should eq "do laundry"
    end

    it "writes the tasks to a file" do
      new_tasks = ["do laundry"] + tasks
      File.should_receive(:write).with(file_path, new_tasks.to_yaml)
      list.prepend("do laundry")
    end
  end

  describe '#remove' do
    context "when position is some number followed by an 'x'" do
      it "removes the first n items" do
        expect {
          list.remove('2x')
        }.to change(list, :length).by(-2)
        list.first.should eq "feed the elephant"
      end
    end

    context "when the position is a number" do
      it "removes the item specified" do
        expect {
          list.remove('2')
        }.to change(list, :length).by(-1)
        expected_tasks = tasks.dup
        expected_tasks.delete_at(2)
        list.tasks.should eq expected_tasks
      end
    end

    context "when the position is trash text" do
      it "removes the first item in the list" do
        expect {
          list.remove('trash')
        }.to change(list, :length).by(-1)
        list.tasks.should eq tasks[1..-1]
      end
    end

    context "when the position is nil" do
      it "removes the first item in the list" do
        expect {
          list.remove(nil)
        }.to change(list, :length).by(-1)
        list.tasks.should eq tasks[1..-1]
      end
    end

    context "when the position is not given" do
      it "removes the first item in the list" do
        expect {
          list.remove
        }.to change(list, :length).by(-1)
        list.tasks.should eq tasks[1..-1]
      end
    end

    it "writes the tasks to a file" do
      new_tasks = tasks[1..-1]
      File.should_receive(:write).with(file_path, new_tasks.to_yaml)
      list.remove
    end
  end

  describe '#walk' do
    it "moves the first task from the list to the end" do
      expect {
        list.walk
      }.to change(list, :last).from(list.last).to(list.first)
    end

    it "writes to a file" do
      new_tasks = tasks[1..-1] << tasks.first
      File.should_receive(:write).with(file_path, new_tasks.to_yaml)
      list.walk
    end

    context "given an integer value" do
      it "moves that many elements to the end" do
        expected_tasks = tasks.rotate(2)
        expect {
          list.walk(2)
        }.to change(list, :tasks).to(expected_tasks)
      end
    end
  end

  describe '#to_s' do
    let(:stars) { '*' * 40 }

    context "when there are no tasks" do
      let(:yaml) { [].to_yaml }

      it "returns two lines of stars and 0 tasks remaining" do
        expected = "#{stars}\n#{stars}\n#{"0 tasks remaining".green}"
        list.to_s.should eq expected
      end
    end

    context 'when there are tasks' do
      it "returns the task with the count in green" do
        expected = "#{stars}\n"
        expected << "1: buy groceries\n"
        expected << "2: wax the dog\n"
        expected << "3: feed the elephant\n"
        expected << "#{stars}\n"
        expected << "3 tasks remaining".green
        list.to_s.should eq expected
      end
    end
  end

end
