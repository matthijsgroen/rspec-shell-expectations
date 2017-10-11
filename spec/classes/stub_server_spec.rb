require 'spec_helper'
require 'socket'
include Rspec::Bash

describe 'StubServer' do
  let(:call_log_manager) {double(CallLogManager)}
  let(:call_conf_manager) {double(CallConfigurationManager)}
  let(:stub_marshaller) { double(RubyStubMarshaller) }
  let(:tcp_server) { double(TCPServer) }
  let(:accept_thread) { double(Thread) }
  subject {StubServer.new(call_log_manager, call_conf_manager, stub_marshaller)}

  context('#start') do
    before do
      allow(accept_thread).to receive(:kill)
      allow(subject).to receive(:accept_loop)
      allow(Thread).to receive(:new)
        .and_yield
        .and_return(accept_thread)
    end
    it('returns the thread that the server is accepting connections on') do
      expect(subject.start(tcp_server)).to eql(accept_thread)
    end
    it('enters the accept loop') do
      expect(subject).to receive(:accept_loop)
        .with(tcp_server)
      subject.start(tcp_server)
    end
  end
  context('#accept_loop') do
    it('accepts the connection and replies') do
      tcp_server = double(TCPServer)
      tcp_socket = double(TCPSocket)
      allow(tcp_server).to receive(:accept)
        .and_return(tcp_socket)
      allow(tcp_socket).to receive(:read)
        .and_return('client_message')
      allow(subject).to receive(:process)
        .with('client_message')
        .and_return('server_message')

      expect(tcp_socket).to receive(:write)
        .with('server_message')
      expect(tcp_socket).to receive(:close)

      subject.accept_loop(tcp_server, false)
    end
  end
  context('#process') do
    it('calls its marshaller to serialize and deserialize messages') do
      client_message = {
        command: 'first_command',
        stdin:   'stdin',
        args:    %w(first_argument second_argument)
      }
      server_message = {
        args:     %w(first_argument second_argument),
        exitcode: 0,
        outputs:  []
      }

      expect(stub_marshaller).to receive(:unmarshal)
        .with('client_message')
        .and_return(client_message)

      expect(subject).to receive(:process_stub_call)
        .with(client_message)
        .and_return(server_message)

      expect(stub_marshaller).to receive(:marshal)
        .with(server_message)
        .and_return('server_message')

      expect(subject.process('client_message'))
        .to eql 'server_message'
    end
  end
  context('#process_stub_call') do
    it('logs the call for the command') do
      expect(call_log_manager).to receive(:add_log)
        .with('first_command', 'stdin', %w(first_argument second_argument))
      allow(call_conf_manager).to receive(:get_best_call_conf)

      subject.process_stub_call({
        command: 'first_command',
        stdin:   'stdin',
        args:    %w(first_argument second_argument)
      })
    end
    it('returns the best matching call configuration for the command') do
      allow(call_log_manager).to receive(:add_log)
      allow(call_conf_manager).to receive(:get_best_call_conf)
        .with('first_command', %w(first_argument second_argument))
        .and_return(
          {
            args:     %w(first_argument second_argument),
            exitcode: 0,
            outputs:  []
          }
        )

      expect(subject.process_stub_call({
        command: 'first_command',
        stdin:   'stdin',
        args:    %w(first_argument second_argument)
      })).to eql(
        {
          args:     %w(first_argument second_argument),
          exitcode: 0,
          outputs:  []
        })
    end
  end
end
