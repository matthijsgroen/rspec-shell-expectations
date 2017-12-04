require 'spec_helper'
include Rspec::Bash

def execute_script(script)
  let(:temp_file) { Tempfile.new('for-testing') }
  let!(:execute_results) do
    if script.include? '<temp file>'
      script.gsub!(/<temp file>/, temp_file.path)
    end
    stdout, stderr, status = stubbed_env.execute_function(
      BashStubScript.path,
      script
    )
    [stdout, stderr, status]
  end
  let(:stdout) { execute_results[0] }
  let(:stderr) { execute_results[1] }
  let(:exitcode) { execute_results[2].exitstatus }
  after do
    if script.include? '<temp file>'
      FileUtils.remove_entry_secure temp_file
    end
  end
end

describe 'BashStub' do
  let(:stubbed_env) { create_stubbed_env(StubbedEnv::RUBY_STUB) }

  context '.create-call-log' do
    context 'with no stdin or arguments' do
      execute_script 'create-call-log first_command 55555'

      it 'makes a call log with just the name and stdin set to blank' do
        expect(stdout.chomp).to eql JSON.pretty_generate(
          Sparsify.sparse(
            {
              command: 'first_command',
              stdin: ''
            }, sparse_array: true
          ), indent: '', space: ''
        )
      end
    end
    context 'with stdin and no arguments' do
      execute_script "echo 'st d\nin' | create-call-log first_command 55555"

      it 'makes a call log with just the name and stdin set to supplied stdin' do
        expect(stdout.chomp).to eql JSON.pretty_generate(
          Sparsify.sparse(
            {
              command: 'first_command',
              stdin: "st d\nin"
            }, sparse_array: true
          ), indent: '', space: ''
        )
      end
    end
    context 'with arguments and no stdin' do
      execute_script 'create-call-log first_command 55555' \
      " first_argument 'second argument' 'third\nargument'"

      it 'makes a call log with the name, stdin set to blank, and the supplied arguments' do
        expect(stdout.chomp).to eql JSON.pretty_generate(
          Sparsify.sparse(
            {
              command: 'first_command',
              stdin: '',
              args: [
                'first_argument',
                'second argument',
                "third\nargument"
              ]
            }, sparse_array: true
          ), indent: '', space: ''
        )
      end
    end
    context 'with arguments and stdin' do
      execute_script(
        "echo 'st d\nin' | create-call-log first_command 55555" \
        " first_argument 'second argument' 'third\nargument'"
      )

      it 'makes a call log with the name, stdin set to supplied stdn, and the supplied arguments' do
        expect(stdout.chomp).to eql JSON.pretty_generate(
          Sparsify.sparse(
            {
              command: 'first_command',
              stdin: "st d\nin",
              args: [
                'first_argument',
                'second argument',
                "third\nargument"
              ]
            }, sparse_array: true
          ), indent: '', space: ''
        )
      end
    end

    context 'with verifyable json-encode stub' do
      before(:all) do
        stubbed_env = create_stubbed_env
        json_encode = stubbed_env.stub_command('json-encode')
        json_encode.outputs('json encoded', to: :stdout)

        @stdout, = stubbed_env.execute_function(
          BashStubScript.path,
          'echo stdin | create-call-log first_command 55555 first_argument second_argument third_argument'
        )
      end

      it 'passes the stdin and args through the json-decode function' do
        expect(@stdout.chomp).to eql JSON.pretty_generate(
          Sparsify.sparse(
            {
              command: 'first_command',
              stdin: 'json encoded',
              args: [
                'json encoded',
                'json encoded',
                'json encoded'
              ]
            }, sparse_array: true
          ), indent: '', space: ''
        )
      end
    end
  end

  context '.send-to-server' do
    context 'with a server port and call log message' do
      before(:all) do
        stubbed_env = create_stubbed_env
        @netcat = stubbed_env.stub_command('nc')
          .outputs('call conf message')

        @stdout, = stubbed_env.execute_function(
          BashStubScript.path,
          'send-to-server 55555 "call log message"'
        )
      end

      it 'calls netcat to send the message to the server port and returns its response' do
        expect(@netcat).to be_called_with_arguments('localhost', '55555')
      end

      it 'calls netcat to send the message to the server port and returns its response' do
        expect(@netcat.with_args('localhost', '55555').stdin).to eql 'call log message'
      end

      it 'calls netcat to send the message to the server port and returns its response' do
        expect(@stdout.chomp).to eql 'call conf message'
      end
    end
  end

  context '.extract-properties' do
    context 'given a standard call conf message' do
      let(:call_conf) do
        JSON.pretty_generate(
          Sparsify.sparse(
            {
              exitcode: 10,
              outputs: [
                {
                  target: 'stdout',
                  content: "stdout\nstdout stdout"
                },
                {
                  target: 'stderr',
                  content: "stderr stderr\nstderr"
                },
                {
                  target: 'tofile',
                  content: "tofile\ntofile tofile"
                }
              ]
            }, sparse_array: true
          ), indent: '', space: ''
        )
      end

      it 'extracts a single value field' do
        stdout, = stubbed_env.execute_function(
          BashStubScript.path,
          "extract-properties '#{call_conf}' 'exitcode'"
        )
        expect(stdout.chomp).to eql '10'
      end

      it 'extracts a multiple value field' do
        stdout, stderr = stubbed_env.execute_function(
          BashStubScript.path,
          "extract-properties '#{call_conf}' 'outputs\\..*\\.content'"
        )
        expect(stdout.chomp).to eql "stdout\\nstdout stdout\nstderr stderr\\nstderr" \
        "\ntofile\\ntofile tofile"
      end
    end
  end

  context '.print-output' do
    context 'given a stdout target and its associated content' do
      execute_script("print-output 'stdout' 'stdout \\\\nstdout\nstdout'")

      it 'prints the output to stdout' do
        expect(stdout.chomp).to eql "stdout \\nstdout\nstdout"
      end

      it 'does not print the output to stderr' do
        expect(stderr.chomp).to eql ''
      end
    end

    context 'given a stderr target and its associated content' do
      execute_script("print-output 'stderr' 'stderr \\\\nstderr\nstderr'")

      it 'prints the output to stderr' do
        expect(stderr.chomp).to eql "stderr \\nstderr\nstderr"
      end

      it 'does not print the output to stdout' do
        expect(stdout.chomp).to eql ''
      end
    end

    context 'given a file target (anything but stderr or stdout)' do
      execute_script "print-output '<temp file>' 'tofile \\\\ntofile\ntofile'"

      it 'prints the output to the file' do
        expect(temp_file.read.chomp).to eql "tofile \\ntofile\ntofile"
      end

      it 'does not print the output to stderr' do
        expect(stderr.chomp).to eql ''
      end

      it 'does not print the output to stdout' do
        expect(stdout.chomp).to eql ''
      end
    end
  end

  context '.json-decode' do
    context 'with an encoded quotation mark' do
      execute_script 'json-decode "\\\\\\""'

      it 'converts \" to "' do
        expect(stdout.chomp).to eql '"'
      end
    end
  end

  context '.json-encode' do
    context 'with a quotation mark' do
      execute_script 'json-encode "\""'

      it 'converts " to \"' do
        expect(stdout.chomp).to eql '\"'
      end
    end
    context 'with a new line character' do
      execute_script "json-encode 'cat\ndog\n'"

      it 'converts \n to escaped \n' do
        expect(stdout.chomp).to eql 'cat\ndog\n'
      end
    end
    context 'with a tab character' do
      execute_script "json-encode '\t'"

      it 'converts \t to escaped \t' do
        expect(stdout.chomp).to eql '\t'
      end
    end
    context 'with a carriage return character' do
      execute_script "json-encode '\r'"

      it 'converts \r to escaped \r' do
        expect(stdout.chomp).to eql '\r'
      end
    end
    context 'with a backspace character' do
      execute_script "json-encode '\b'"

      it 'converts \r to escaped \r' do
        expect(stdout.chomp).to eql '\b'
      end
    end
    context 'with a unicode character' do
      execute_script 'json-encode "@"'

      it 'does not convert the character' do
        expect(stdout.chomp).to eql '@'
      end
    end
    context 'with a forward slash character' do
      execute_script 'json-encode "/"'

      it 'does not convert the character' do
        expect(stdout.chomp).to eql '/'
      end
    end
    context 'with an escaped character' do
      execute_script 'json-encode "\u"'

      it 'converts \u to \\u' do
        expect(stdout.chomp).to eql '\\\\u'
      end
    end
  end

  context '.main' do
    context 'with stdin, command, port and arguments' do
      before(:all) do
        stubbed_env = create_stubbed_env
        @create_call_log = stubbed_env.stub_command('create-call-log')
          .outputs('call log')
        @send_to_server = stubbed_env.stub_command('send-to-server')
          .outputs('call conf')
        @extract_properties = stubbed_env.stub_command('extract-properties')
        @print_output = stubbed_env.stub_command('print-output')

        @extract_properties.with_args('call conf', 'outputs\..*\.target')
          .outputs("stdout\nstderr\ntofile\n")
        @extract_properties.with_args('call conf', 'outputs\..*\.content')
          .outputs("std out\nstd err\nto file\n")
        @extract_properties.with_args('call conf', 'exitcode')
          .outputs("3\n")

        _, _, @status = stubbed_env.execute_function(
          BashStubScript.path,
          'echo "stdin" | main first_command 55555 first_argument second_argument'
        )
      end

      it 'creates a call log from the stdin and args' do
        expect(@create_call_log).to be_called_with_arguments(
          'first_command', '55555', 'first_argument', 'second_argument'
        )
        expect(@create_call_log.stdin.chomp).to eql 'stdin'
      end
      it 'sends that call log to the server' do
        expect(@send_to_server).to be_called_with_arguments(
          '55555', 'call log'
        )
      end
      it 'extracts the target list from the call conf returned by the server' do
        expect(@extract_properties).to be_called_with_arguments(
          'call conf', 'outputs\..*\.target'
        )
      end
      it 'extracts the content list from the call conf returned by the server' do
        expect(@extract_properties).to be_called_with_arguments(
          'call conf', 'outputs\..*\.content'
        )
      end
      it 'extracts the exit code from the call conf returned by the server' do
        expect(@extract_properties).to be_called_with_arguments(
          'call conf', 'exitcode'
        )
      end
      it 'prints the extracted outputs' do
        expect(@print_output).to be_called_with_arguments(
          'stdout', 'std out'
        )
        expect(@print_output).to be_called_with_arguments(
          'stderr', 'std err'
        )
        expect(@print_output).to be_called_with_arguments(
          'tofile', 'to file'
        )
      end
      it 'exits with the extracted exit code' do
        expect(@status.exitstatus).to eql 3
      end
    end
  end
end
