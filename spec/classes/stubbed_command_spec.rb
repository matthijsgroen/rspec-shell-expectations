require 'English'
require 'rspec/shell/expectations'

# TODO - the below specs test implementation, until the goofy wiring of StubbedCommand => StubbedCall => CallLog is sorted out

describe 'StubbedCommand' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  before(:each) do
    allow(FileUtils).to receive(:cp)
  end

  context '#called_with_args?' do
    before(:each) do
      @subject = Rspec::Shell::Expectations::StubbedCommand.new('command', Dir.mktmpdir)
      @stubbed_call = double(Rspec::Shell::Expectations::StubbedCall)
    end
    context 'with only a series of arguments' do
      it 'passes the check to its StubbedCall\'s #called_with_args? method' do
        expect(@subject).to receive(:with_args).with(no_args).and_return(@stubbed_call)
        expect(@stubbed_call).to receive(:called_with_args?).with('first_argument', 'second_argument', anything).and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument')
      end
    end
    context 'with only a series of arguments and a position' do
      it 'passes the check to its StubbedCall\'s #called_with_args? method' do
        expect(@subject).to receive(:with_args).with(no_args).and_return(@stubbed_call)
        expect(@stubbed_call).to receive(:called_with_args?).with('first_argument', 'second_argument', position: 0).and_return(true)
        @subject.called_with_args?('first_argument', 'second_argument', position: 0)
      end
    end
  end

  context '#with_args' do
    before(:each) do
      @subject = Rspec::Shell::Expectations::StubbedCommand.new('command', Dir.mktmpdir)
    end
    context 'with arguments provided' do
      it 'creates a new StubbedCall with those arguments' do
        expect(Rspec::Shell::Expectations::StubbedCall).to receive(:new).with(anything, anything, ['first_sub_command', 'second_sub_command'])
        @subject.with_args('first_sub_command', 'second_sub_command')
      end
    end
    context 'with no arguments provided' do
      it 'creates a new StubbedCall with no arguments' do
        expect(Rspec::Shell::Expectations::StubbedCall).to receive(:new).with(anything, anything, [])
        @subject.with_args
      end
    end
  end
end