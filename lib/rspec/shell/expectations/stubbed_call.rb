module Rspec
  module Shell
    module Expectations
      # A specific call with arguments on a StubbedCommand
      class StubbedCall
        def initialize(config, call_log, args)
          @config, @call_log, @args = config, call_log, args
        end

        def returns_exitstatus(statuscode)
          @config.set_exitcode(statuscode, @args)
          @config.write
        end

        def outputs(content, to: :stdout)
          @config.set_output(content, to, @args)
          @config.write
        end

        def called?
          return false unless @call_log.exist?
          @call_log.called_with_args?(*@args)
        end
      end
    end
  end
end
