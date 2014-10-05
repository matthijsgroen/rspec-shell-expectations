module Rspec
  module Shell
    module Expectations
      # A specific call with arguments on a StubbedCommand
      class StubbedCall
        def initialize(config, args)
          @config, @args = config, args
        end

        def returns_exitstatus(statuscode)
          @config.set_exitcode(statuscode, @args)
          @config.write
        end
      end
    end
  end
end
