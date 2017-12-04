require 'spec_helper'
include Rspec::Bash

describe 'StubbedCommand' do
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }

  describe '#outputs' do
    describe 'target stdout' do
      context 'when given no arguments to match' do
        let(:output) do
          command1_stub
            .outputs("\nhello\n", to: :stdout)
          output, = stubbed_env.execute_inline('command1 first_argument second_argument')
          output
        end

        it 'outputs the expected output to stdout' do
          expect(output).to eql "\nhello\n"
        end
      end
      context 'when given an exact argument match' do
        let(:output) do
          command1_stub
            .with_args('first_argument', 'second_argument')
            .outputs("\nhello\n", to: :stdout)
          output, = stubbed_env.execute_inline('command1 first_argument second_argument')
          output
        end

        it 'outputs the expected output to stdout' do
          expect(output).to eql "\nhello\n"
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
    describe 'target stderr' do
      context 'when given no arguments to match' do
        let(:error) do
          command1_stub
            .outputs("\nhello\n", to: :stderr)
          _, error, = stubbed_env.execute_inline('command1 first_argument second_argument')
          error
        end

        it 'outputs the expected error to stderr' do
          expect(error).to eql "\nhello\n"
        end
      end
      context 'when given an exact argument match' do
        let(:error) do
          command1_stub
            .with_args('first_argument', 'second_argument')
            .outputs("\nhello\n", to: :stderr)
          _, error, = stubbed_env.execute_inline('command1 first_argument second_argument')
          error
        end

        it 'outputs the expected error to stderr' do
          expect(error).to eql "\nhello\n"
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

    describe 'target file path' do
      let(:temp_file) { Tempfile.new('for-testing') }
      context 'when given no arguments to match' do
        before(:each) do
          command1_stub
            .outputs("\nhello\n", to: temp_file.path)
          stubbed_env.execute_inline('command1 first_argument second_argument')
        end

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql "\nhello\n"
        end
      end
      context 'when given an exact argument match' do
        before(:each) do
          command1_stub
            .with_args('first_argument', 'second_argument')
            .outputs("\nhello\n", to: temp_file.path)
          stubbed_env.execute_inline('command1 first_argument second_argument')
        end

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql "\nhello\n"
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

      describe 'when given a passed argument for a filename' do
        let(:dynamic_file) { Pathname.new('output-piglet.txt') }
        before(:each) do
          command1_stub
            .outputs('i have a dynamic file name', to: ['output-', :arg2, '.txt'])
          stubbed_env.execute_inline('command1 poglet piglet')
        end

        it 'outputs the expected content to the file' do
          expect(dynamic_file.read).to eql 'i have a dynamic file name'
        end

        after(:each) do
          FileUtils.remove_entry_secure dynamic_file
        end
      end
    end
  end
end
