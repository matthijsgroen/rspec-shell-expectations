require 'spec_helper'
include Rspec::Bash

describe 'CallLogManager' do
  subject { CallLogManager.new }

  context 'with a command call configuration' do
    let(:first_command_call_log) do
      call_log = double(CallLog)
      allow(CallLog).to receive(:new)
        .and_return(call_log).once
      call_log
    end

    context '#add_log' do
      it 'passes the logs to their respective calllogs' do
        expect(first_command_call_log).to receive(:add_log)
          .with('stdin', %w(first_argument second_argument)).twice

        subject.add_log('first_command', 'stdin', %w(first_argument second_argument))
        subject.add_log('first_command', 'stdin', %w(first_argument second_argument))
      end
    end

    context '#stdin_for_args' do
      it 'gets the respective stdin for an array of arguments' do
        allow(first_command_call_log).to receive(:stdin_for_args)
          .with(%w(first_argument second_argument))
          .and_return('first_command stdin for [first_argument, second_argument]')
        allow(first_command_call_log).to receive(:stdin_for_args)
          .with(%w(third_argument fourth_argument))
          .and_return('first_command stdin for [third_argument, fourth_argument]')

        expect(subject.stdin_for_args('first_command', %w(first_argument second_argument)))
          .to eql('first_command stdin for [first_argument, second_argument]')
        expect(subject.stdin_for_args('first_command', %w(third_argument fourth_argument)))
          .to eql('first_command stdin for [third_argument, fourth_argument]')
      end
    end

    context '#call_count' do
      it 'gets the respective call count for an array of arguments' do
        allow(first_command_call_log).to receive(:call_count)
          .with(%w(first_argument second_argument))
          .and_return(2)
        allow(first_command_call_log).to receive(:call_count)
          .with(%w(third_argument fourth_argument))
          .and_return(3)

        expect(subject.call_count('first_command', %w(first_argument second_argument)))
          .to eql(2)
        expect(subject.call_count('first_command', %w(third_argument fourth_argument)))
          .to eql(3)
      end
    end

    context '#called_with_args?' do
      it 'gets the respective call status for the arguments' do
        allow(first_command_call_log).to receive(:called_with_args?)
          .with(%w(first_argument second_argument))
          .and_return(true)
        allow(first_command_call_log).to receive(:called_with_args?)
          .with(%w(third_argument fourth_argument))
          .and_return(false)

        expect(subject.called_with_args?('first_command', %w(first_argument second_argument)))
          .to eql(true)
        expect(subject.called_with_args?('first_command', %w(third_argument fourth_argument)))
          .to eql(false)
      end
    end

    context '#called_with_no_args?' do
      it 'gets the respective call status for the arguments' do
        allow(first_command_call_log).to receive(:called_with_no_args?)
          .and_return(true)

        expect(subject.called_with_no_args?('first_command'))
          .to eql(true)
      end
    end
  end
end
