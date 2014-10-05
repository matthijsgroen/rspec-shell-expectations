module Rspec
  module Shell
    module Expectations
      # Command that produces specific output
      # and monitors input
      class StubbedCommand
        def initialize(command, dir)
          @dir, @command = dir, command
          FileUtils.cp('bin/stub', File.join(dir, command))
          @call_configuration = CallConfiguration.new(
            Pathname.new(dir).join("#{command}_stub.yml")
          )
        end

        def with_args(*args)
          StubbedCall.new(@call_configuration, args)
        end

        def returns_exitstatus(statuscode)
          with_args.returns_exitstatus(statuscode)
        end
      end
    end
  end
end
