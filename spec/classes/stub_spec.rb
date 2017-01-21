require 'spec_helper'

describe 'bin/stub' do
  let(:subject_path) { File.expand_path('stub', "#{File.dirname(__FILE__)}/../../bin") }
  let(:stub_call_pathname) { instance_double('Pathname') }
  let(:stub_directory_pathname) { instance_double('Pathname') }
  let(:stub_config_pathname) { instance_double('Pathname') }
  let(:stub_output_string_pathname) { instance_double('Pathname') }
  let(:stub_call_file) { StringIO.new }
  let(:stub_config_file) { StringIO.new }
  let(:stub_stderr_file) { StringIO.new }
  let(:stub_stdout_file) { StringIO.new }
  let(:stub_output_string_file) { StringIO.new }
  let(:exit_code_list) { [] }

  before(:each) do
    allow(stub_call_pathname).to receive(:open).with('a')
      .and_yield(stub_call_file)
    allow(stub_output_string_pathname).to receive(:open).with('w')
      .and_yield(stub_output_string_file)
    allow(stub_config_pathname).to receive(:exist?)

    allow(Pathname).to receive(:new).with('a unique file name')
      .and_return(stub_output_string_pathname)
    allow(Pathname).to receive(:new).with('first_argumentsecond_argumenta unique file name')
      .and_return(stub_output_string_pathname)
    allow(Pathname).to receive(:new).with(File.dirname(subject_path))
      .and_return(stub_directory_pathname)

    allow(stub_directory_pathname).to receive(:join).with('stub_calls.yml')
      .and_return(stub_call_pathname)
    allow(stub_directory_pathname).to receive(:join).with('stub_stub.yml')
      .and_return(stub_config_pathname)

    $stderr = stub_stderr_file
    $stdout = stub_stdout_file
    allow($stdin).to receive(:tty?).and_return(false)

    allow_any_instance_of(Kernel).to receive(:exit) do |_, exit_code|
      exit_code_list << exit_code
      raise SystemExit
    end
  end

  context 'with no configuration' do
    before(:each) do
      allow(stub_config_pathname).to receive(:exist?).and_return(false)
    end
    context 'and it is called with no arguments' do
      before(:each) do
        ARGV.replace []
      end
      context 'and no stdin' do
        let(:stub_call_log) do
          allow($stdin).to receive(:read).and_return('')
          load subject_path

          YAML.safe_load(stub_call_file.string)
        end

        it 'logs a blank STDIN' do
          expect(stub_call_log[0]['stdin']).to be_empty
        end

        it 'logs no arguments' do
          expect(stub_call_log[0]['args']).to be_nil
        end

        it 'exits with appropriate code' do
          expect(exit_code_list[0]).to be_nil
        end
      end
      context 'and some stdin' do
        let(:stub_call_log) do
          allow($stdin).to receive(:read).and_return("dog\ncat\n")
          load subject_path

          YAML.safe_load(stub_call_file.string)
        end

        it 'logs some STDIN' do
          expect(stub_call_log[0]['stdin']).to eql "dog\ncat\n"
        end

        it 'logs no arguments' do
          expect(stub_call_log[0]['args']).to be_nil
        end

        it 'exits with appropriate code' do
          expect(exit_code_list[0]).to be_nil
        end
      end
    end
    context 'and it is called with some arguments' do
      before(:each) do
        ARGV.replace %w(first_argument second_argument)
      end
      context 'and no stdin' do
        let(:stub_call_log) do
          allow($stdin).to receive(:read).and_return('')
          load subject_path

          YAML.safe_load(stub_call_file.string)
        end

        it 'logs a blank STDIN' do
          expect(stub_call_log[0]['stdin']).to be_empty
        end

        it 'logs some arguments' do
          expect(stub_call_log[0]['args']).to eql %w(first_argument second_argument)
        end

        it 'exits with appropriate code' do
          expect(exit_code_list[0]).to be_nil
        end
      end
      context 'and some stdin' do
        let(:stub_call_log) do
          allow($stdin).to receive(:read).and_return("dog\ncat\n")
          load subject_path

          YAML.safe_load(stub_call_file.string)
        end

        it 'logs some STDIN' do
          expect(stub_call_log[0]['stdin']).to eql "dog\ncat\n"
        end

        it 'logs some arguments' do
          expect(stub_call_log[0]['args']).to eql %w(first_argument second_argument)
        end

        it 'exits with appropriate code' do
          expect(exit_code_list[0]).to be_nil
        end
      end
    end
    context 'and it is called several times in a row' do
      let(:stub_call_log) do
        ARGV.replace []
        allow($stdin).to receive(:read).and_return('')
        load subject_path

        ARGV.replace []
        allow($stdin).to receive(:read).and_return("dog\ncat\n")
        load subject_path

        ARGV.replace %w(first_argument second_argument)
        allow($stdin).to receive(:read).and_return('')
        load subject_path

        ARGV.replace %w(first_argument second_argument)
        allow($stdin).to receive(:read).and_return("dog\ncat\n")
        load subject_path

        YAML.safe_load(stub_call_file.string)
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

      it 'exits with appropriate code for first call' do
        expect(exit_code_list[0]).to be_nil
      end

      it 'exits with appropriate code for second call' do
        expect(exit_code_list[1]).to be_nil
      end

      it 'exits with appropriate code for third call' do
        expect(exit_code_list[2]).to be_nil
      end

      it 'exits with appropriate code for fourth call' do
        expect(exit_code_list[3]).to be_nil
      end
    end
  end
  context 'with some configuration' do
    before(:each) do
      allow($stdin).to receive(:read).and_return('')
      allow(stub_config_pathname).to receive(:exist?).and_return(true)
    end
    context 'with configurations that does not end up matching calls' do
      before(:each) do
        stdout_configuration = [
          {
            args: ['super_special_argument'],
            outputs: [
              {
                target: :stderr,
                content: "no args content\n"
              }
            ],
            statuscode: 1
          }
        ]
        allow(stub_config_pathname).to receive(:read).and_return(stdout_configuration.to_yaml)
      end
      context 'and it is called with no arguments' do
        before(:each) do
          ARGV.replace []
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'exits with appropriate code' do
          expect(exit_code_list[0]).to eql 0
        end

        it 'outputs nothing to stdout' do
          expect(stub_stdout_file.string).to eql ''
        end

        it 'outputs nothing to stderr' do
          expect(stub_stderr_file.string).to eql ''
        end
      end
      context 'and it is called with some arguments' do
        before(:each) do
          ARGV.replace ['wrongo']
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'exits with appropriate code' do
          expect(exit_code_list[0]).to eql 0
        end

        it 'outputs nothing to stdout' do
          expect(stub_stdout_file.string).to eql ''
        end

        it 'outputs nothing to stderr' do
          expect(stub_stderr_file.string).to eql ''
        end
      end
      context 'and it is called several times in a row' do
        before(:each) do
          ARGV.replace []
          begin
            load subject_path
          rescue SystemExit
          end

          ARGV.replace ['wrongo']
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'exits with appropriate code for first call' do
          expect(exit_code_list[0]).to eql 0
        end

        it 'exits with appropriate code for second call' do
          expect(exit_code_list[1]).to eql 0
        end

        it 'outputs nothing to stdout' do
          expect(stub_stdout_file.string).to eql ''
        end

        it 'outputs nothing to stderr' do
          expect(stub_stderr_file.string).to eql ''
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
                content: "no args content\n"
              },
              {
                target: :stderr,
                content: "more no args content\n"
              }
            ],
            statuscode: 1
          },
          {
            args: %w(first_argument second_argument),
            outputs: [
              {
                target: :stdout,
                content: "some args content\n"
              },
              {
                target: :stdout,
                content: "more some args content\n"
              }
            ],
            statuscode: 2
          },
          {
            args: %w(first_argument second_argument third_argument),
            outputs: [
              {
                target: 'a unique file name',
                content: "some args file content\n"
              },
              {
                target: 'a unique file name',
                content: "more some args file content\n"
              }
            ],
            statuscode: 3
          },
          {
            args: %w(first_argument second_argument third_argument fourth_argument),
            outputs: [
              {
                target: [:arg1, :arg2, 'a unique file name'],
                content: "some concatenated filename output\n"
              },
              {
                target: [:arg1, :arg2, 'a unique file name'],
                content: "more some concatenated filename output\n"
              }
            ],
            statuscode: 4
          }
        ]
        allow(stub_config_pathname).to receive(:read).and_return(stdout_configuration.to_yaml)
      end
      context 'and it is called with no arguments' do
        before(:each) do
          ARGV.replace []
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'matches the no argument configuration exactly and prints its stderr content' do
          expect(stub_stderr_file.string).to eql "no args content\nmore no args content\n"
        end

        it 'matches the no argument configuration exactly and exits with its exit code' do
          expect(exit_code_list[0]).to eql 1
        end
      end
      context 'and it is called with two arguments' do
        before(:each) do
          ARGV.replace %w(first_argument second_argument)
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'matches the two argument configuration exactly and prints its stdout content' do
          expect(stub_stdout_file.string).to eql "some args content\nmore some args content\n"
        end

        it 'matches the two argument configuration exactly and exits with its exit code' do
          expect(exit_code_list[0]).to eql 2
        end
      end
      context 'and it is called with three arguments' do
        before(:each) do
          ARGV.replace %w(first_argument second_argument third_argument)
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'matches the three argument configuration exactly and prints its file content' do
          expect(stub_output_string_file.string).to eql 'some args file content
more some args file content
'
        end

        it 'matches the three argument configuration exactly and exits with its exit code' do
          expect(exit_code_list[0]).to eql 3
        end
      end
      context 'and it is called with four arguments' do
        before(:each) do
          ARGV.replace %w(first_argument second_argument third_argument fourth_argument)
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'matches the four argument configuration exactly and prints its named file content' do
          expect(stub_output_string_file.string).to eql 'some concatenated filename output
more some concatenated filename output
'
        end

        it 'matches the four argument configuration exactly and exits with its exit code' do
          expect(exit_code_list[0]).to eql 4
        end
      end
      context 'and it is called several times in a row' do
        before(:each) do
          ARGV.replace []
          begin
            load subject_path
          rescue SystemExit
          end

          ARGV.replace %w(first_argument second_argument)
          begin
            load subject_path
          rescue SystemExit
          end

          ARGV.replace %w(first_argument second_argument third_argument)
          begin
            load subject_path
          rescue SystemExit
          end

          ARGV.replace %w(first_argument second_argument third_argument fourth_argument)
          begin
            load subject_path
          rescue SystemExit
          end
        end

        it 'prints the expected output to stderr' do
          expect(stub_stderr_file.string).to eql "no args content\nmore no args content\n"
        end

        it 'prints the expected output to stdout' do
          expect(stub_stdout_file.string).to eql "some args content\nmore some args content\n"
        end

        it 'prints the expected output to the string named file' do
          expect(stub_output_string_file.string).to eql 'some args file content
more some args file content
some concatenated filename output
more some concatenated filename output
'
        end

        it 'exits with appropriate code for first call' do
          expect(exit_code_list[0]).to eql 1
        end

        it 'exits with appropriate code for second call' do
          expect(exit_code_list[1]).to eql 2
        end

        it 'exits with appropriate code for third call' do
          expect(exit_code_list[2]).to eql 3
        end

        it 'exits with appropriate code for fourth call' do
          expect(exit_code_list[3]).to eql 4
        end
      end
    end
  end
end
