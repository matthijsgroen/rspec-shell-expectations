require 'English'
require 'rspec/shell/expectations'

describe 'StubbedCommand' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  before(:each) do
    allow(FileUtils).to receive(:cp)
  end

  context '#called_with_args?' do
    before(:each) do
      @call_log = double(Rspec::Shell::Expectations::CallLog)
      allow(Rspec::Shell::Expectations::CallLog).to receive(:new).and_return(@call_log)
      @subject = Rspec::Shell::Expectations::StubbedCommand.new('command', Dir.mktmpdir)
    end
    context 'with only a series of arguments' do
      it 'passes the check to its CallLog\'s #called_with_args? method' do
        expect(@call_log).to receive(:called_with_args?).with('first_argument', 'second_argument', anything).and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument')
      end
    end
    context 'with a series of arguments and a position' do
      it 'passes the check to its CallLog\'s #called_with_args? method' do
        expect(@call_log).to receive(:called_with_args?).with('first_argument', 'second_argument', position: 0).and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument', position: 0)
      end
    end
  end
end