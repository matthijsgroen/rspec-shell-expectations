require 'digest'

module Rspec
  module Bash
    class StubbedCommand
      attr_reader :command, :arguments

      def initialize(command, call_log_manager, call_conf_manager)
        @command = command
        @arguments = []
        @call_log_manager = call_log_manager
        @call_conf_manager = call_conf_manager
      end

      def with_args(*args)
        @arguments = args
        self
      end

      def called?
        @call_log_manager.called_with_args?(@command, @arguments)
      end

      def called_with_no_args?
        @call_log_manager.called_with_no_args?(@command)
      end

      def called_with_args?(*args)
        @call_log_manager.called_with_args?(@command, args)
      end

      def call_count(*args)
        @call_log_manager.call_count(@command, args)
      end

      def stdin
        @call_log_manager.stdin_for_args(@command, @arguments)
      end

      def returns_exitstatus(exitcode)
        @call_conf_manager.set_exitcode(@command, exitcode, @arguments)
        self
      end

      def outputs(contents, to: :stdout)
        @call_conf_manager.add_output(@command, contents, to, @arguments)
        self
      end

      def call_log
        @call_log_manager.call_log(@command)
      end

      def inspect
        if @arguments.any?
          "<Stubbed #{@call_configuration.command.inspect} " \
            "args: #{@arguments.join(' ').inspect}>"
        else
          "<Stubbed #{@call_configuration.command.inspect}>"
        end
      end
    end
  end
end
