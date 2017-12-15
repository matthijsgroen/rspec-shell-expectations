module Rspec
  module Bash
    class CallConfigurationManager
      def initialize
        @call_confs = Hash.new { |hash, key| hash[key] = CallConfiguration.new }
      end

      def set_exitcode(command, exitcode, args)
        @call_confs[command]
          .set_exitcode(exitcode, args)
      end

      def add_output(command, output, target, args)
        @call_confs[command]
          .add_output(output, target, args)
      end

      def get_best_call_conf(command, args)
        @call_confs[command]
          .get_best_call_conf(args)
      end
    end
  end
end
