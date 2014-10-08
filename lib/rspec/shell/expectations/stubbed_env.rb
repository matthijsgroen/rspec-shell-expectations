require 'tmpdir'
require 'English'
require 'open3'

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
          Open3.capture3("#{env} #{command}")
        end

        private

        def env
          "PATH=#{@dir}:$PATH"
        end
      end
    end
  end
end
