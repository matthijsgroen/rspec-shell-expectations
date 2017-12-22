require 'spec_helper'
include Rspec::Bash

describe 'StubbedCommand' do
  let(:call_log_manager) { double(CallLogManager) }
  let(:call_conf_manager) { double(CallConfigurationManager) }

  subject { StubbedCommand.new('command', call_log_manager, call_conf_manager) }

  context '#called_with_args?' do
    context 'with only a series of arguments' do
      it 'passes the check to its CallLog\'s #called_with_args? method' do
        expect(call_log_manager).to receive(:called_with_args?)
          .with('command', %w(first_argument second_argument))
          .and_return(true)
        subject.called_with_args?('first_argument', 'second_argument')
      end
    end
  end

  context '#with_args' do
    before do
      subject.with_args('argument_one', 'argument_two')
    end

    it 'sets the arguments array on the StubbedCommand to the arguments that were passed in' do
      expect(subject.arguments).to eql %w(argument_one argument_two)
    end
  end

  context '#call_count' do
    it 'returns value returned from call_log argument count when there are no arguments' do
      expect(call_log_manager).to(
        receive(:call_count)
          .with('command', [])
          .and_return('arbitrary return value')
      )

      expect(subject.call_count).to eql 'arbitrary return value'
    end
    it 'returns value returned from call_log argument count when there is only one argument' do
      expect(call_log_manager).to receive(:call_count)
        .with('command', ['only arg'])
        .and_return('arbitrary return value')

      expect(subject.call_count('only arg')).to eql 'arbitrary return value'
    end
    it 'returns value returned from call_log argument count when there are multiple  arguments' do
      expect(call_log_manager).to receive(:call_count)
        .with('command', ['first arg', 'second arg'])
        .and_return('arbitrary return value')

      expect(subject.call_count('first arg', 'second arg')).to eql 'arbitrary return value'
    end
  end

  context '#called?' do
    it 'returns false when call_log is not called with args' do
      expect(call_log_manager).to receive(:called_with_args?).and_return(false)

      expect(subject.called?).to be_falsey
    end
    it 'returns true when call_log is called with args' do
      expect(call_log_manager).to receive(:called_with_args?).and_return(true)

      expect(subject.called?).to be_truthy
    end
  end

  context '#stdin' do
    it 'returns stdin from call log when call_log exists' do
      expect(call_log_manager).to receive(:stdin_for_args).and_return('arbitrary stdin')

      expect(subject.stdin).to eql 'arbitrary stdin'
    end
  end

  context '#returns_exitstatus' do
    it 'sets the exitcode on call_configuration' do
      expect(call_conf_manager).to receive(:set_exitcode).with('command', 'exit code', anything)

      subject.returns_exitstatus 'exit code'
    end
    it 'returns itself' do
      expect(call_conf_manager).to receive(:set_exitcode)

      expect(subject.returns_exitstatus(anything)).to eql subject
    end
  end

  context '#outputs' do
    it 'sets the output on the call_configuration' do
      expect(call_conf_manager).to receive(:add_output).with(
        'command',
        'contents',
        'stderr',
        anything
      )

      subject.outputs('contents', to: 'stderr')
    end
    it 'sets the "to" value for the output to stdout by default' do
      expect(call_conf_manager).to receive(:add_output).with(
        'command',
        'contents',
        :stdout,
        anything
      )

      subject.outputs('contents')
    end
    it 'returns itself' do
      expect(call_conf_manager).to receive(:add_output)

      expect(subject.outputs(anything)).to eql subject
    end
  end
end
