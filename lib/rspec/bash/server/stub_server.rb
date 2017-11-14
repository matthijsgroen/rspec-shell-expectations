require 'socket'

module Rspec
  module Bash
    class StubServer
      def initialize(call_log_manager, call_conf_manager, stub_marshaller)
        @call_log_manager = call_log_manager
        @call_conf_manager = call_conf_manager
        @stub_marshaller = stub_marshaller
      end

      def start(tcp_server)
        Thread.new do
          accept_loop(tcp_server)
        end
      end

      def accept_loop(tcp_server, loop_forever = true)
        loop do
          tcp_socket = tcp_server.accept
          message = process(tcp_socket.read)
          tcp_socket.write(message)
          tcp_socket.close
          break unless loop_forever
        end
      end

      def process(client_message)
        client_call = @stub_marshaller.unmarshal(client_message)
        server_conf = process_stub_call(client_call)
        @stub_marshaller.marshal(server_conf)
      end

      def process_stub_call(stub_call)
        @call_log_manager.add_log(
          stub_call[:command],
          stub_call[:stdin],
          stub_call[:args]
        )
        @call_conf_manager.get_best_call_conf(
          stub_call[:command],
          stub_call[:args]
        )
      end
    end
  end
end
