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
        attr_reader :dir

        def initialize
          @dir = Dir.mktmpdir
          ENV['PATH'] = "#{@dir}:#{ENV['PATH']}"
          at_exit { cleanup }
        end

        def cleanup
          paths = (ENV['PATH'].split ':') - [@dir]
          ENV['PATH'] = paths.join ':'
          FileUtils.remove_entry_secure @dir if Pathname.new(@dir).exist?
        end

        def stub_command(command)
          wrap_command command
          StubbedCommand.new command, @dir
        end

        def execute(command, env_vars = {})
          full_command=wrap_execute(<<-multiline_script
            #{env} source #{command} 2> #{wrapped_error_path}
          multiline_script
          )

          Open3.capture3(env_vars, full_command)
        end

        def execute_function(script, command, env_vars = {})
          full_command=wrap_execute(<<-multiline_script
            source #{script} 2> #{wrapped_error_path}
            #{env} #{command}
          multiline_script
          )

          Open3.capture3(env_vars, full_command)
        end

        def execute_inline(command_string, env_vars = {})
          temp_command_path=Dir::Tmpname.make_tmpname("#{@dir}/inline-", nil)
          File.write(temp_command_path, command_string)
          execute(temp_command_path, env_vars)
        end

        private

        def wrap_command(command)
          command_path = File.join(@dir, command)
          overrides_path = File.join(@dir, "#{command}_overrides.sh")
          template = ERB.new File.new(overrides_filepath).read, nil, "%"
          overrides_content = template.result(binding)
          File.write(overrides_path, overrides_content)
        end

        def wrap_execute(execution_snippet)
          <<-multiline_script
            /usr/bin/env bash -c '
            # load in command and function overrides
            source <(cat #{@dir}/*_overrides.sh)

            #{execution_snippet}
            command_exit_code=$?

            # filter stderr for readonly problems
            grep -v "readonly function" #{wrapped_error_path}  >&2

            # return original exit code
            exit ${command_exit_code}'
          multiline_script
        end

        def wrapped_error_path
          "#{@dir}/errors"
        end

        def env
          "PATH=#{@dir}:$PATH"
        end

        def overrides_filepath
          project_root.join('bin', 'overrides.sh.erb')
        end

        def project_root
          Pathname.new(File.dirname(File.expand_path(__FILE__)))
              .join('..', '..', '..', '..')
        end
      end
    end
  end
end
