require 'spec_helper'
include Rspec::Bash

describe 'CallConfigurationManager' do
  subject { CallConfigurationManager.new }

  context 'with a command call configuration' do
    let(:first_command_call_conf) do
      call_conf = double(CallConfiguration)
      allow(CallConfiguration).to receive(:new)
        .and_return(call_conf).once
      call_conf
    end
    context '#set_exitcode' do
      it 'passes the exit code along to the correct CallConfiguration' do
        expect(first_command_call_conf).to receive(:set_exitcode)
          .with(0, %w(first_argument second_argument)).once
        expect(first_command_call_conf).to receive(:set_exitcode)
          .with(1, %w(first_argument second_argument)).once

        subject.set_exitcode('first_command', 0, %w(first_argument second_argument))
        subject.set_exitcode('first_command', 1, %w(first_argument second_argument))
      end
    end
    context '#add_output' do
      it 'passes the output addition along to the correct CallConfiguration' do
        expect(first_command_call_conf).to receive(:add_output)
          .with('hello', :stdout, %w(first_argument second_argument)).once
        expect(first_command_call_conf).to receive(:add_output)
          .with('world', :stderr, %w(first_argument second_argument)).once

        subject.add_output('first_command', 'hello', :stdout, %w(first_argument second_argument))
        subject.add_output('first_command', 'world', :stderr, %w(first_argument second_argument))
      end
    end
    context '#get_best_call_conf' do
      it 'passes the query along to the correct CallConfiguration' do
        allow(first_command_call_conf).to receive(:get_best_call_conf)
          .with(%w(first_argument second_argument))
          .and_return({
            args:     %w(first_argument second_argument),
            exitcode: 0,
            outputs:  []
          }).once
        allow(first_command_call_conf).to receive(:get_best_call_conf)
          .with(%w(first_argument other_argument))
          .and_return({
            args:     %w(first_argument other_argument),
            exitcode: 1,
            outputs:  []
          }).once

        expect(subject.get_best_call_conf('first_command', %w(first_argument second_argument)))
          .to eql({
            args:     %w(first_argument second_argument),
            exitcode: 0,
            outputs:  []
          })
        expect(subject.get_best_call_conf('first_command', %w(first_argument other_argument)))
          .to eql({
            args:     %w(first_argument other_argument),
            exitcode: 1,
            outputs:  []
          })
      end
    end
  end
end


