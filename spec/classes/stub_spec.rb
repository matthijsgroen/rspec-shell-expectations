require 'English'
require 'rspec/bash'
require 'yaml'

describe 'bin/stub' do
  let(:subject_path) { File.expand_path('stub', "#{File.dirname(__FILE__)}/../../bin") }
  let(:stub_call_pathname) { instance_double('Pathname') }
  let(:stub_config_pathname) { instance_double('Pathname') }
  let(:stub_output_pathname) { instance_double('Pathname') }
  let(:stub_call_file) { StringIO.new }
  let(:stub_config_file) { StringIO.new }
  let(:stub_output_file) { StringIO.new }

  before(:each) do
    allow(stub_call_pathname).to receive(:open).with('a').and_yield(stub_call_file)
    allow(stub_config_pathname).to receive(:exist?)
    allow_any_instance_of(Pathname).to receive(:join).with('stub_calls.yml')
      .and_return(stub_call_pathname)
    allow_any_instance_of(Pathname).to receive(:join).with('stub_stub.yml')
      .and_return(stub_config_pathname)
    allow_any_instance_of(Kernel).to receive(:exit)
  end

  context 'when called multiple times from a non-tty session' do
    before(:each) do
      allow(STDIN).to receive(:tty?).and_return(false)
    end
    context 'with no configuration' do
      context 'with different combinations of STDIN and arguments' do
        let(:stub_call_log) do
          ARGV.replace []
          allow(STDIN).to receive(:read).and_return('')
          load subject_path

          ARGV.replace []
          allow(STDIN).to receive(:read).and_return("dog\ncat\n")
          load subject_path

          ARGV.replace %w(first_argument second_argument)
          allow(STDIN).to receive(:read).and_return('')
          load subject_path

          ARGV.replace %w(first_argument second_argument)
          allow(STDIN).to receive(:read).and_return("dog\ncat\n")
          load subject_path

          YAML.load(stub_call_file.string)
        end

        it 'logs a blank STDIN for the first call' do
          expect(stub_call_log[0]['stdin']).to be_empty
        end

        it 'logs no arguments for the first call' do
          expect(stub_call_log[0]['args']).to be_nil
        end

        it 'logs some STDIN for the second call' do
          expect(stub_call_log[1]['stdin']).to eql "dog\ncat\n"
        end

        it 'logs no arguments for the second call' do
          expect(stub_call_log[1]['args']).to be_nil
        end

        it 'logs a blank STDIN for the third call' do
          expect(stub_call_log[2]['stdin']).to be_empty
        end

        it 'logs some arguments for the third call' do
          expect(stub_call_log[2]['args']).to eql %w(first_argument second_argument)
        end

        it 'logs some STDIN for the fourth call' do
          expect(stub_call_log[3]['stdin']).to eql "dog\ncat\n"
        end

        it 'logs some arguments for the fourth call' do
          expect(stub_call_log[3]['args']).to eql %w(first_argument second_argument)
        end
      end
    end
    context 'with configurations for stdout, stderr and file behaviour' do
      before(:each) do
        stdout_configuration = [
          {
            args: [],
            outputs: [
              {
                target: :stderr,
                content: 'no args content'
              }
            ]
          },
          {
            args: %w(first_argument second_argument),
            outputs: [
              {
                target: :stdout,
                content: 'some args content'
              }
            ]
          },
          {
            args: %w(first_argument second_argument third_argument),
            outputs: [
              {
                target: 'a unique file name',
                content: 'some args file content'
              }
            ]
          }
        ]
        allow(STDIN).to receive(:read).and_return('')
        allow(stub_config_pathname).to receive(:exist?).and_return(true)
        allow_any_instance_of(Pathname).to receive(:open).with('w').and_yield(stub_output_file)
        allow(stub_config_pathname).to receive(:read).and_return(stdout_configuration.to_yaml)
      end
      context 'with some arguments that trigger stderr' do
        before(:each) do
          ARGV.replace []
        end

        it 'prints the expected output to stdout' do
          expect(STDERR).to receive(:print).with('no args content')
          load subject_path
        end
      end
      context 'with some arguments that trigger stdout' do
        before(:each) do
          ARGV.replace %w(first_argument second_argument)
        end

        it 'prints the expected output to stdout' do
          expect(STDOUT).to receive(:print).with('some args content')
          load subject_path
        end
      end
      context 'with some arguments that trigger file output' do
        before(:each) do
          ARGV.replace %w(first_argument second_argument third_argument)
        end

        it 'prints the expected output to stdout' do
          load subject_path
          expect(stub_output_file.string).to eql 'some args file content'
        end
      end
    end
  end
  context 'when called multiple times from a tty session' do
    before(:each) do
      allow(STDIN).to receive(:tty?).and_return(true)
    end
    context 'with no configuration' do
      context 'with different combinations of STDIN and arguments' do
        let(:stub_call_log) do
          ARGV.replace []
          allow(STDIN).to receive(:read).and_return('')
          load subject_path

          ARGV.replace []
          allow(STDIN).to receive(:read).and_return("dog\ncat\n")
          load subject_path

          ARGV.replace %w(first_argument second_argument)
          allow(STDIN).to receive(:read).and_return('')
          load subject_path

          ARGV.replace %w(first_argument second_argument)
          allow(STDIN).to receive(:read).and_return("dog\ncat\n")
          load subject_path

          YAML.load(stub_call_file.string)
        end

        it 'logs a blank STDIN for the first call' do
          expect(stub_call_log[0]['stdin']).to be_nil
        end

        it 'logs no arguments for the first call' do
          expect(stub_call_log[0]['args']).to be_nil
        end

        it 'logs some STDIN for the second call' do
          expect(stub_call_log[1]['stdin']).to be_nil
        end

        it 'logs no arguments for the second call' do
          expect(stub_call_log[1]['args']).to be_nil
        end

        it 'logs a blank STDIN for the third call' do
          expect(stub_call_log[2]['stdin']).to be_nil
        end

        it 'logs some arguments for the third call' do
          expect(stub_call_log[2]['args']).to eql %w(first_argument second_argument)
        end

        it 'logs some STDIN for the fourth call' do
          expect(stub_call_log[3]['stdin']).to be_nil
        end

        it 'logs some arguments for the fourth call' do
          expect(stub_call_log[3]['args']).to eql %w(first_argument second_argument)
        end
      end
    end
  end
end
