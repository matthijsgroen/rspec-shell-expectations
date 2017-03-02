require 'spec_helper'

describe 'Stub command output' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }

  let(:script) do
    <<-SCRIPT
      command1
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

  describe 'stubbing standard-out' do
    it 'changes standard-out' do
      command1_stub.outputs('hello', to: :stdout)
      output, error, _status = stubbed_env.execute "#{script_path} 2>/dev/null"

      expect(output).to eql 'hello'
      expect(error).to be_empty
    end
    context 'when given an exact argument match' do
      let(:output) do
        command1_stub
          .with_args('first_argument', 'second_argument')
          .outputs('hello', to: :stdout)
        output, = stubbed_env.execute_inline('command1 first_argument second_argument')
        output
      end

      it 'outputs the expected output to stdout' do
        expect(output).to eql 'hello'
      end
    end
    context 'when given an anything argument match' do
      let(:output) do
        command1_stub
          .with_args('first_argument', anything)
          .outputs('i respond to anything', to: :stdout)
        output, = stubbed_env.execute_inline('command1 first_argument piglet')
        output
      end

      it 'outputs the expected output to stdout' do
        expect(output).to eql 'i respond to anything'
      end
    end
    context 'when given any_args argument match' do
      let(:output) do
        command1_stub
          .with_args(any_args)
          .outputs('i respond to any_args', to: :stdout)
        output, = stubbed_env.execute_inline('command1 poglet piglet')
        output
      end

      it 'outputs the expected output to stdout' do
        expect(output).to eql 'i respond to any_args'
      end
    end
    context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
      let(:output) do
        command1_stub
          .with_args(instance_of(String), instance_of(String))
          .outputs('i respond to instance_of', to: :stdout)
        output, = stubbed_env.execute_inline('command1 poglet 1')
        output
      end

      it 'outputs the expected output to stdout' do
        expect(output).to eql 'i respond to instance_of'
      end
    end
    context 'when given regex argument match' do
      let(:output) do
        command1_stub
          .with_args(/p.glet/, /p.glet/)
          .outputs('i respond to regex', to: :stdout)
        output, = stubbed_env.execute_inline('command1 poglet piglet')
        output
      end

      it 'outputs the expected output to stdout' do
        expect(output).to eql 'i respond to regex'
      end
    end
  end

  # TODO: it is a bug that these require a \n in the output
  describe 'stubbing standard-err' do
    it 'changes standard-error' do
      command1_stub.outputs('world', to: :stderr)
      output, error, _status = stubbed_env.execute "#{script_path} 1>/dev/null"
      expect(error).to eql "world\n"
      expect(output).to be_empty
    end
    context 'when given an exact argument match' do
      let(:error) do
        command1_stub
          .with_args('first_argument', 'second_argument')
          .outputs('hello', to: :stderr)
        _, error, = stubbed_env.execute_inline('command1 first_argument second_argument')
        error
      end

      it 'outputs the expected error to stderr' do
        expect(error).to eql "hello\n"
      end
    end
    context 'when given an anything argument match' do
      let(:error) do
        command1_stub
          .with_args('first_argument', anything)
          .outputs('i respond to anything', to: :stderr)
        _, error, = stubbed_env.execute_inline('command1 first_argument piglet')
        error
      end

      it 'outputs the expected error to stderr' do
        expect(error).to eql "i respond to anything\n"
      end
    end
    context 'when given any_args argument match' do
      let(:error) do
        command1_stub
          .with_args(any_args)
          .outputs('i respond to any_args', to: :stderr)
        _, error, = stubbed_env.execute_inline('command1 poglet piglet')
        error
      end

      it 'outputs the expected error to stderr' do
        expect(error).to eql "i respond to any_args\n"
      end
    end
    context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
      let(:error) do
        command1_stub
          .with_args(instance_of(String), instance_of(String))
          .outputs('i respond to instance_of', to: :stderr)
        _, error, = stubbed_env.execute_inline('command1 poglet 1')
        error
      end

      it 'outputs the expected error to stderr' do
        expect(error).to eql "i respond to instance_of\n"
      end
    end
    context 'when given regex argument match' do
      let(:error) do
        command1_stub
          .with_args(/p.glet/, /p.glet/)
          .outputs('i respond to regex', to: :stderr)
        _, error, = stubbed_env.execute_inline('command1 poglet piglet')
        error
      end

      it 'outputs the expected error to stderr' do
        expect(error).to eql "i respond to regex\n"
      end
    end
  end

  describe 'stubbing contents to file' do
    let(:filename) { 'test-log.nice' }
    after do
      f = Pathname.new(filename)
      f.delete if f.exist?
    end

    it 'write data to a file' do
      command1_stub.outputs('world', to: filename)
      output, error, _status = stubbed_env.execute script_path.to_s

      expect(error).to be_empty
      expect(output).to be_empty
      expect(Pathname.new(filename).read).to eql 'world'
    end

    let(:temp_file) { Tempfile.new('for-testing') }
    context 'when given an exact argument match' do
      before(:each) do
        command1_stub
          .with_args('first_argument', 'second_argument')
          .outputs('hello', to: temp_file.path)
        stubbed_env.execute_inline('command1 first_argument second_argument')
      end

      it 'outputs the expected content to the file' do
        expect(temp_file.read).to eql 'hello'
      end
    end
    context 'when given an anything argument match' do
      before(:each) do
        command1_stub
          .with_args('first_argument', anything)
          .outputs('i respond to anything', to: temp_file.path)
        stubbed_env.execute_inline('command1 first_argument second_argument')
      end

      it 'outputs the expected content to the file' do
        expect(temp_file.read).to eql 'i respond to anything'
      end
    end
    context 'when given any_args argument match' do
      before(:each) do
        command1_stub
          .with_args(any_args)
          .outputs('i respond to any_args', to: temp_file.path)
        stubbed_env.execute_inline('command1 poglet piglet')
      end

      it 'outputs the expected content to the file' do
        expect(temp_file.read).to eql 'i respond to any_args'
      end
    end
    context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
      before(:each) do
        command1_stub
          .with_args(instance_of(String), instance_of(String))
          .outputs('i respond to instance_of', to: temp_file.path)
        stubbed_env.execute_inline('command1 poglet 1')
      end

      it 'outputs the expected content to the file' do
        expect(temp_file.read).to eql 'i respond to instance_of'
      end
    end
    context 'when given regex argument match' do
      before(:each) do
        command1_stub
          .with_args(/p.glet/, /p.glet/)
          .outputs('i respond to regex', to: temp_file.path)
        stubbed_env.execute_inline('command1 poglet piglet')
      end

      it 'outputs the expected content to the file' do
        expect(temp_file.read).to eql 'i respond to regex'
      end
    end

    describe 'using passed argument as filename' do
      let(:script) do
        <<-SCRIPT
          command1 input output
        SCRIPT
      end

      let(:passed_filename) { ['hello-', :arg2, '.foo'] }
      let(:filename) { 'hello-output.foo' }

      it 'writes data to an interpolated filename' do
        command1_stub.outputs('world', to: passed_filename)
        stubbed_env.execute script_path.to_s

        expect(Pathname.new(filename).read).to eql 'world'
      end
    end
  end

  describe 'stubbing commands with arguments passed to stdout' do
    let(:script) do
      <<-SCRIPT
        command1 input output
      SCRIPT
    end

    it 'outputs correctly when all arguments match' do
      command1_stub
        .with_args('input', 'output')
        .outputs('world', to: :stdout)
      output, error, _status = stubbed_env.execute script_path.to_s

      expect(error).to be_empty
      expect(output).to eql 'world'
    end

    it 'does not output when called with extra arguments, even if some match' do
      command1_stub
        .with_args('input', 'output', 'anything')
        .outputs('arbitrary string', to: :stdout)
      output, error, _status = stubbed_env.execute script_path.to_s

      expect(error).to be_empty
      expect(output).to be_empty
    end

    it 'does not output when called with only one matching argument out of many' do
      command1_stub
        .with_args('input')
        .outputs('arbitrary string', to: :stdout)
      output, error, _status = stubbed_env.execute script_path.to_s

      expect(error).to be_empty
      expect(output).to be_empty
    end
  end
end
