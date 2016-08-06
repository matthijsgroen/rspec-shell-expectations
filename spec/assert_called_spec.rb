require 'English'
require 'rspec/shell/expectations'
require 'rspec/shell/expectations/matchers/called_with_arg.rb'

describe 'Assert called' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:first_command) { stubbed_env.stub_command('first_command') }
  let!(:second_command) { stubbed_env.stub_command('second_command') }
  let!(:flagged_command_stub) { stubbed_env.stub_command('flagged_command') }

  let(:script) do
    <<-SCRIPT
      first_command "foo bar"
      second_command foo bar
      second_command foo boo
      flagged_command -d flagged_arg
    SCRIPT
  end
  let(:script_path) { Pathname.new '/tmp/test_script.sh' }

  before do
    script_path.open('w') { |f| f.puts script }
    script_path.chmod 0777
  end

  after do
    script_path.delete
  end

  subject do
    stubbed_env.execute script_path.to_s
  end

  describe 'assert called' do
    it 'returns called status' do
      subject
      expect(first_command).to be_called
    end

    context 'assert with args' do
      it 'returns called status' do
        subject
        expect(first_command.with_args('foo bar')).to be_called
        expect(first_command.with_args('foo')).not_to be_called
      end
    end

    context 'with arg check' do
      it 'matches against entire set of arguments' do
        subject
        expect(second_command).to be_called_with_arg('foo')
        expect(second_command).to be_called_with_arg('bar')
        expect(second_command).to_not be_called_with_arg('baz')
      end
    end

    context 'with arg at position' do
      it 'matches against argument position' do
        subject
        expect(second_command).to be_called_with_arg('foo').at_position(0)
        expect(second_command).to be_called_with_arg('bar').at_position(1)
        expect(second_command).to_not be_called_with_arg('foo').at_position(1)
        expect(second_command).to_not be_called_with_arg('bar').at_position(0)
        expect(second_command).to be_called_with_arg('boo').at_position(1)
      end
    end

    context 'with flag passed in to command' do
      it 'matches against flagged parameter' do
        subject
        expect(flagged_command_stub).to be_called_with_arg('flagged_arg').with_flag('-d')
        expect(flagged_command_stub).to_not be_called_with_arg('flagged_arg').with_flag('-no_call_flag')
      end
    end

    context 'with same command called twice' do
      it 'matches against correct number of invocations' do
        subject
        expect(second_command).to_not be_called_with_arg('foo').times(2)
      end
    end

    context 'with command called exactly once' do
      it 'matches against correct number of invocations' do
        subject
        expect(first_command).to be_called_with_arg('foo bar').times(1)
      end
    end

    context 'with command called with arbitrary arguments' do
        it 'matches when command is called zero times with target argument' do
        subject
        expect(first_command).to be_called_with_arg('zoo').times(0)
      end
    end

    describe 'assertion message' do
      it 'provides a helpful message' do
        expect(first_command.inspect).to eql '<Stubbed "first_command">'
        expect(first_command.with_args('foo bar').inspect).to \
          eql '<Stubbed "first_command" args: "foo bar">'
      end
    end
  end
end
