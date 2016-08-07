require 'English'
require 'rspec/shell/expectations'

# TODO - the below specs test implementation, until the goofy wiring of StubbedCommand => StubbedCall => CallLog is sorted out

describe 'StubbedCall' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }

  context '#called_with_args?' do
    context 'with only a series of arguments' do
      before(:each) do
        @subject = Rspec::Shell::Expectations::StubbedCall.new('command', 'call_log', ['first_argument', 'second_argument'])
      end
      it 'passes the check to its CallLog\'s #called_with_args? method' do
        expect(@subject.call_log).to receive(:called_with_args?).with('first_argument', 'second_argument', anything).and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument')
      end
    end
    context 'with only a series of arguments and a position' do
      before(:each) do
        @subject = Rspec::Shell::Expectations::StubbedCall.new('command', 'call_log', ['first_argument', 'second_argument'])
      end
      it 'passes the check to its CallLog\'s #called_with_args? method' do
        expect(@subject.call_log).to receive(:called_with_args?).with(
            'first_argument',
            'second_argument',
            sub_command_series: [
                'first_argument',
                'second_argument'
            ],
            position: 0
        ).and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument', position: 0)
      end
    end
    context 'with no sub-commands, a series of arguments and a position' do
      before(:each) do
        @subject = Rspec::Shell::Expectations::StubbedCall.new('command', 'call_log', [])
      end
      it 'passes the check to its CallLog\'s #called_with_args? method' do
        expect(@subject.call_log).to receive(:called_with_args?).with(
            'first_argument',
            'second_argument',
            sub_command_series: [],
            position: 0
        ).and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument', position: 0)
      end
    end
  end
end