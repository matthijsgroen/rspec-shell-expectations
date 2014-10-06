require 'tmpdir'
require 'English'

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
          StubbedCommand.new command, @dir
        end

        def execute(command)
          `#{stub_path} #{command}`
          $CHILD_STATUS
        end

        private

        def stub_path
          "PATH=#{@dir}:$PATH"
        end
      end
    end
  end
end
