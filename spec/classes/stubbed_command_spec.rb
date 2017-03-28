require 'spec_helper'
include Rspec::Bash

describe 'StubbedCommand' do
  include_examples 'manage a :temp_directory'

  before(:each) do
    allow(FileUtils).to receive(:cp)
  end

  context '#called_with_args?' do
    before(:each) do
      @call_log = double(Rspec::Bash::CallLog)
      allow(Rspec::Bash::CallLog).to receive(:new).and_return(@call_log)
      @subject = Rspec::Bash::StubbedCommand.new('command', temp_directory)
    end
    context 'with only a series of arguments' do
      it 'passes the check to its CallLog\'s #called_with_args? method' do
        expect(@call_log).to receive(:called_with_args?)
          .with('first_argument', 'second_argument')
          .and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument')
      end
    end
  end

  context '#with_args' do
    before(:each) do
      @subject = Rspec::Bash::StubbedCommand.new('command', temp_directory)
      @subject.with_args('argument_one', 'argument_two')
    end
    it 'sets the arguments array on the StubbedCommand to the arguments that were passed in' do
      expect(@subject.arguments).to eql %w(argument_one argument_two)
    end
  end

  context '#call_count' do
    before(:each) do
      @call_log = double(Rspec::Bash::CallLog)
      allow(Rspec::Bash::CallLog).to receive(:new).and_return(@call_log)
      @subject = Rspec::Bash::StubbedCommand.new('command', temp_directory)
    end
    it 'returns value returned from call_log argument count when there are no arguments' do
      expect(@call_log).to receive(:call_count).with([]).and_return('arbitrary return value')
      expect(@subject.call_count([])).to eql 'arbitrary return value'
    end
    it 'returns value returned from call_log argument count when there is only one argument' do
      expect(@call_log).to receive(:call_count)
        .with(['only arg'])
        .and_return('arbitrary return value')
      expect(@subject.call_count(['only arg'])).to eql 'arbitrary return value'
    end
    it 'returns value returned from call_log argument count when there are multiple  arguments' do
      expect(@call_log).to receive(:call_count).with(['first arg', 'second arg'])
        .and_return('arbitrary return value')
      expect(@subject.call_count(['first arg', 'second arg'])).to eql 'arbitrary return value'
    end
  end

  context '#called?' do
    before(:each) do
      @call_log = double(Rspec::Bash::CallLog)
      allow(Rspec::Bash::CallLog).to receive(:new).and_return(@call_log)
      @subject = Rspec::Bash::StubbedCommand.new('command', temp_directory)
    end
    it 'returns false when there is no call_log' do
      expect(@call_log).to receive(:exist?).and_return(false)
      expect(@subject.called?).to be_falsey
    end
    it 'returns false when call_log is not called with args' do
      expect(@call_log).to receive(:exist?).and_return(true)
      expect(@call_log).to receive(:called_with_args?).and_return(false)
      expect(@subject.called?).to be_falsey
    end
    it 'returns true when call_log is called with args' do
      expect(@call_log).to receive(:exist?).and_return(true)
      expect(@call_log).to receive(:called_with_args?).and_return(true)
      expect(@subject.called?).to be_truthy
    end
  end

  context '#stdin' do
    before(:each) do
      @call_log = double(Rspec::Bash::CallLog)
      allow(Rspec::Bash::CallLog).to receive(:new).and_return(@call_log)
      @subject = Rspec::Bash::StubbedCommand.new('command', temp_directory)
    end
    it 'returns nil when there is no call_log' do
      expect(@call_log).to receive(:exist?).and_return(false)
      expect(@subject.stdin).to be_nil
    end
    it 'returns stdin from call log when call_log exists' do
      expect(@call_log).to receive(:exist?).and_return(true)
      expect(@call_log).to receive(:stdin_for_args).and_return('arbitrary stdin')
      expect(@subject.stdin).to eql 'arbitrary stdin'
    end
  end

  context '#returns_exitstatus' do
    before(:each) do
      @call_configuration = double(Rspec::Bash::CallConfiguration)
      allow(Rspec::Bash::CallConfiguration).to receive(:new).and_return(@call_configuration)
      @subject = Rspec::Bash::StubbedCommand.new('command', temp_directory)
    end
    it 'sets the exitcode on call_configuration' do
      expect(@call_configuration).to receive(:set_exitcode).with('exit code', anything)
      @subject.returns_exitstatus 'exit code'
    end
    it 'returns itself' do
      expect(@call_configuration).to receive(:set_exitcode)
      expect(@subject.returns_exitstatus(anything)).to eql @subject
    end
  end

  context '#outputs' do
    before(:each) do
      @call_configuration = double(Rspec::Bash::CallConfiguration)
      allow(Rspec::Bash::CallConfiguration).to receive(:new).and_return(@call_configuration)
      @subject = Rspec::Bash::StubbedCommand.new('command', temp_directory)
    end
    it 'sets the output on the call_configuration' do
      expect(@call_configuration).to receive(:add_output).with('contents', 'stderr', anything)
      @subject.outputs('contents', to: 'stderr')
    end
    it 'sets the "to" value for the output to stdout by default' do
      expect(@call_configuration).to receive(:add_output).with('contents', :stdout, anything)
      @subject.outputs('contents')
    end
    it 'returns itself' do
      expect(@call_configuration).to receive(:add_output)
      expect(@subject.outputs(anything)).to eql @subject
    end
  end
end
