require 'tmpdir'

module Rspec
  module Shell
    # Define stubbed environment to set and assert expectations
    module Expectations
      def create_stubbed_env
        StubbedEnv.new
      end

      # A shell environment that can manipulate behaviour
      # of executables
      class StubbedEnv
        def initialize
          @dir = Dir.mktmpdir
          at_exit { FileUtils.remove_entry_secure @dir }
        end

        def stub_command(command)
          FileUtils.cp('bin/stub', File.join(@dir, command))
        end

        def execute(command)
          `#{stub_path} #{command}`
        end

        private

        def stub_path
          "PATH=#{@dir}:$PATH"
        end
      end
    end
  end
end
