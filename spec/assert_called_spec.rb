require 'English'
require 'rspec/shell/expectations'
require 'rspec/shell/expectations/matchers/called_with_arg.rb'

describe 'Assert called' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }
  let!(:command2_stub) { stubbed_env.stub_command('command2') }
  let!(:flagged_command_stub) { stubbed_env.stub_command('flagged_command') }

  let(:script) do
    <<-SCRIPT
      command1 "foo bar"
      command2 foo bar
      command2 foo boo
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
      expect(command1_stub).to be_called
    end

    context 'assert with args' do
      it 'returns called status' do
        subject
        expect(command1_stub.with_args('foo bar')).to be_called
        expect(command1_stub.with_args('foo')).not_to be_called
      end
    end

    context 'with arg check' do
      it 'matches against entire set of arguments' do
        subject
        expect(command2_stub).to be_called_with_arg('foo')
        expect(command2_stub).to be_called_with_arg('bar')
        expect(command2_stub).to_not be_called_with_arg('baz')
      end
    end

    context 'with arg at position' do
      it 'matches against argument position' do
        subject
        expect(command2_stub).to be_called_with_arg('foo').at_position(0)
        expect(command2_stub).to be_called_with_arg('bar').at_position(1)
        expect(command2_stub).to_not be_called_with_arg('foo').at_position(1)
        expect(command2_stub).to_not be_called_with_arg('bar').at_position(0)
        expect(command2_stub).to be_called_with_arg('boo').at_position(1)
      end
    end

    context 'with flag passed in to command' do
      it 'matches against flagged parameter' do
        subject
        expect(flagged_command_stub).to be_called_with_arg('flagged_arg').with_flag('-d')
        expect(flagged_command_stub).to_not be_called_with_arg('flagged_arg').with_flag('-no_call_flag')
      end
    end

    describe 'assertion message' do
      it 'provides a helpful message' do
        expect(command1_stub.inspect).to eql '<Stubbed "command1">'
        expect(command1_stub.with_args('foo bar').inspect).to \
          eql '<Stubbed "command1" args: "foo bar">'
      end
    end
  end
end
