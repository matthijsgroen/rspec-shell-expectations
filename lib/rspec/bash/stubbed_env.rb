require 'tmpdir'
require 'English'
require 'open3'

# TODO: see about breaking StubbedEnv into more SOLID classes
# TODO: add tests for isolating wrapper and stub utilities
# TODO: make all tests more consistent
# TODO: clean up tests you touched
# TODO: get ruby stub tests trued up to what is in bash stub tests
# TODO: enforce the nil call log args that just kind of works for bash stub
# TODO: look into converting wrapper to not use ERB
# TODO: get better testing around target interpolation stuff

module Rspec
  module Bash
    def create_stubbed_env(stub_type = StubbedEnv::BASH_STUB)
      StubbedEnv.new(stub_type)
    end

    class StubbedEnv
      RUBY_STUB = :ruby_stub
      BASH_STUB = :bash_stub
      DISALLOWED_COMMANDS = %w(/usr/bin/env bash readonly function).freeze

      attr_accessor :function_override_list

      def initialize(stub_type = StubbedEnv::BASH_STUB)
        @stub_type = stub_type
        @stub_marshaller_mappings = {
          RUBY_STUB => RubyStubMarshaller,
          BASH_STUB => BashStubMarshaller
        }
        @stub_function_mappings = {
          RUBY_STUB => RubyStubFunction,
          BASH_STUB => BashStubFunction
        }
        @function_override_list = []
        create_stub_server
        at_exit { cleanup }
      end

      def cleanup
        FileUtils.remove_entry_secure wrapper_output_path if Pathname.new(wrapper_output_path).exist?
        FileUtils.remove_entry_secure stderr_output_path if Pathname.new(stderr_output_path).exist?
      end

      def create_stub_server
        tcp_server = TCPServer.new('localhost', 0)
        stub_marshaller = @stub_marshaller_mappings[@stub_type].new

        @stub_server_port = tcp_server.addr[1]
        @call_log_manager = CallLogManager.new
        @call_conf_manager = CallConfigurationManager.new

        stub_server = StubServer.new(
          @call_log_manager,
          @call_conf_manager,
          stub_marshaller
        )
        stub_server.start(tcp_server)
      end

      def stub_command(command)
        check_if_command_is_allowed(command)
        add_function_override_for_command(command)
        StubbedCommand.new(
          command,
          @call_log_manager,
          @call_conf_manager
        )
      end

      def execute(command, env_vars = {})
        full_command = wrap_script_with_function_overrides("source #{command}")
        Open3.capture3(env_vars, full_command)
      end

      def execute_function(script, command, env_vars = {})
        full_command = wrap_script_with_function_overrides("source #{script}\n#{command}")
        Open3.capture3(env_vars, full_command)
      end

      def execute_inline(command_string, env_vars = {})
        temp_command_path = Dir::Tmpname.make_tmpname(File.join(Dir.tmpdir, 'inline-'), nil)
        File.write(temp_command_path, command_string)
        stdout, stderr, status = execute(temp_command_path, env_vars)
        File.delete(temp_command_path)
        [stdout, stderr, status]
      end

      def wrap_script_with_function_overrides(script)
        wrapper_template = ERB.new(File.new(wrapper_input_path).read, nil, '%')
        File.open(wrapper_output_path, 'w') do |file|
          file.write(wrapper_template.result(binding))
        end
        File.chmod(0755, wrapper_output_path)

        wrapper_output_path
      end

      def wrapper_input_path
        File.join(project_root, 'bin', 'wrapper.sh.erb')
      end

      def wrapper_output_path
        File.join(Dir.tmpdir, "wrapper-#{@stub_server_port}.sh")
      end

      def stderr_output_path
        File.join(Dir.tmpdir, "stderr-#{@stub_server_port}.tmp")
      end

      private

      def check_if_command_is_allowed(command)
        if DISALLOWED_COMMANDS.include? command
          raise("Not able to stub command #{command}. Reserved for use by test wrapper.")
        end
      end

      def add_function_override_for_command(command)
        stub_function = @stub_function_mappings[@stub_type].new(command, @stub_server_port)
        function_override_string = <<-multiline_string
#{stub_function.header}
#{stub_function.body}
#{stub_function.footer}
        multiline_string
        @function_override_list << function_override_string.chomp
      end

      def project_root
        File.expand_path(
          File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..')
        )
      end
    end
  end
end
