require 'spec_helper'
include Rspec::Bash

describe 'StubbedEnv' do
  subject { StubbedEnv.new(StubbedEnv::RUBY_STUB) }
  let(:server_thread) { double(Thread) }
  let!(:tcp_server) do
    tcp_server = double(TCPServer)
    allow(tcp_server).to receive(:addr)
      .and_return(['ADDR', 4000])
    allow(TCPServer).to receive(:new)
      .with('localhost', 0)
      .and_return(tcp_server)
    tcp_server
  end
  let!(:log_manager) do
    log_manager = double(CallLogManager)
    allow(CallLogManager).to receive(:new)
      .and_return(log_manager)
    log_manager
  end
  let!(:conf_manager) do
    conf_manager = double(CallConfigurationManager)
    allow(CallConfigurationManager).to receive(:new)
      .and_return(conf_manager)
    conf_manager
  end
  let!(:stub_marshaller) do
    stub_marshaller = double(RubyStubMarshaller)
    allow(RubyStubMarshaller).to receive(:new)
      .and_return(stub_marshaller)
    stub_marshaller
  end
  let!(:stub_server) do
    stub_server = double(StubServer)
    allow(stub_server).to receive(:start)
      .and_return(server_thread)
    allow(StubServer).to receive(:new)
      .with(log_manager, conf_manager, stub_marshaller)
      .and_return(stub_server)
    stub_server
  end
  context '#initialize' do
    it 'creates and starts a StubServer' do
      allow(server_thread).to receive(:kill)

      expect(StubServer).to receive(:new)
        .with(log_manager, conf_manager, stub_marshaller)
        .and_return(stub_server)

      expect(stub_server).to receive(:start)
        .with(tcp_server)

      StubbedEnv.new(StubbedEnv::RUBY_STUB)
    end
  end
  context '#stub_command' do
    let!(:stub_command) do
      stub_command = double(StubbedCommand)
      allow(StubbedCommand).to receive(:new)
        .and_return(stub_command)
      stub_command
    end
    before do
      first_command_stub_function = double(RubyStubFunction)
      second_command_stub_function = double(RubyStubFunction)

      allow(first_command_stub_function).to receive(:header)
        .and_return('first_command header')
      allow(first_command_stub_function).to receive(:body)
        .and_return('first_command body')
      allow(first_command_stub_function).to receive(:footer)
        .and_return('first_command footer')
      allow(second_command_stub_function).to receive(:header)
        .and_return('second_command header')
      allow(second_command_stub_function).to receive(:body)
        .and_return('second_command body')
      allow(second_command_stub_function).to receive(:footer)
        .and_return('second_command footer')

      allow(RubyStubFunction).to receive(:new).with('first_command', anything)
        .and_return(first_command_stub_function)
      allow(RubyStubFunction).to receive(:new).with('second_command', anything)
        .and_return(second_command_stub_function)
    end

    it 'adds the call conf and log managers to the command' do
      expect(StubbedCommand).to receive(:new)
        .with('first_command', log_manager, conf_manager)

      command = subject.stub_command('first_command')
      expect(command).to equal(stub_command)
    end
    it 'adds the command to the function override list' do
      expect(RubyStubFunction).to receive(:new)
        .with('first_command', 4000)
      expect(RubyStubFunction).to receive(:new)
        .with('second_command', 4000)

      subject.stub_command('first_command')
      subject.stub_command('second_command')

      expect(subject.function_override_list).to eql [
        "first_command header\nfirst_command body\nfirst_command footer",
        "second_command header\nsecond_command body\nsecond_command footer"
      ]
    end
  end
  context '#wrap_script_with_function_overrides' do
    let(:script) do
      'echo hello world'
    end
    before do
      subject.function_override_list = %w(first_command second_command)
    end
    it 'calls the script that it created' do
      wrapped_script = subject.wrap_script_with_function_overrides(script)
      expect(wrapped_script).to eql File.join(Dir.tmpdir, 'wrapper-4000.sh')
    end
  end
  context '#execute' do
    it 'wraps the file to execute and sends it to Open3' do
      expect(subject).to receive(:wrap_script_with_function_overrides)
        .with('source file_to_execute')
        .and_return('wrapped script')
      expect(Open3).to receive(:capture3)
        .with({ 'DOG' => 'cat' }, 'wrapped script')

      subject.execute('file_to_execute', 'DOG' => 'cat')
    end
  end
  context('#execute_function') do
    it 'wraps the file to execute and sends it to Open3' do
      expect(subject).to receive(:wrap_script_with_function_overrides)
        .with("source file_to_execute\nfunction_to_execute")
        .and_return('wrapped script')
      expect(Open3).to receive(:capture3)
        .with({ 'DOG' => 'cat' }, 'wrapped script')

      subject.execute_function('file_to_execute', 'function_to_execute', 'DOG' => 'cat')
    end
  end
  context '#execute_inline' do
    before do
      allow(Dir::Tmpname).to receive(:make_tmpname)
        .with(File.join(Dir.tmpdir, 'inline-'), anything)
        .and_return('file_to_execute')
      allow(subject).to receive(:wrap_script_with_function_overrides)
      allow(Open3).to receive(:capture3)
    end
    it 'puts the inline script into a file' do
      expect(File).to receive(:write)
        .with('file_to_execute', 'inline script to execute')
      expect(File).to receive(:delete)
        .with('file_to_execute')
      subject.execute_inline('inline script to execute', 'DOG' => 'cat')
    end
    it 'wraps the file to execute and sends it to Open3' do
      expect(subject).to receive(:wrap_script_with_function_overrides)
        .with('source file_to_execute')
        .and_return('wrapped script')
      expect(Open3).to receive(:capture3)
        .with({ 'DOG' => 'cat' }, 'wrapped script')
      subject.execute_inline('inline script to execute', 'DOG' => 'cat')
    end
  end
  context '#cleanup' do
    it 'cleans up its wrapper and stderr files' do
      existing_file = double(File)
      allow(existing_file).to receive(:exist?)
        .and_return true
      allow(Pathname).to receive(:new)
        .with(File.join(Dir.tmpdir, 'wrapper-4000.sh'))
        .and_return(existing_file)
      allow(Pathname).to receive(:new)
        .with(File.join(Dir.tmpdir, 'stderr-4000.tmp'))
        .and_return(existing_file)

      expect(FileUtils).to receive(:remove_entry_secure)
        .with(File.join(Dir.tmpdir, 'wrapper-4000.sh'))
      expect(FileUtils).to receive(:remove_entry_secure)
        .with(File.join(Dir.tmpdir, 'stderr-4000.tmp'))

      subject.cleanup
    end
  end
end
