require 'yaml'

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

        # Configuration of a stubbed command
        class CallConfiguration
          def initialize(config_path)
            @config_path = config_path
            @configuration = {}
          end

          def set_exitcode(statuscode, args = [])
            @configuration[args] ||= {}
            @configuration[args][:statuscode] = statuscode
          end

          def write
            structure = []
            @configuration.each do |args, results|
              call = {
                args: args
              }.merge results
              structure << call
            end

            @config_path.open('w') do |f|
              f.puts structure.to_yaml
            end
          end
        end
      end
    end
  end
end
