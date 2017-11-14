module Rspec
  module Bash
    module Wrapper
      class BashWrapper
        def initialize(port)
          @port = port
          @override_list = []
          at_exit { cleanup }
        end

        def wrap_script(script)
          wrapper_template = ERB.new(File.new(wrapper_input_path).read, nil, '%')
          File.open(wrapper_output_path, 'w') do |file|
            file.write(wrapper_template.result(binding))
          end
          File.chmod(0755, wrapper_output_path)

          wrapper_output_path
        end

        def wrapper_input_path
          File.join(project_root, 'bin', 'bash_wrapper.sh.erb')
        end

        def wrapper_output_path
          File.join(Dir.tmpdir, "wrapper-#{@port}.sh")
        end

        def stderr_output_path
          File.join(Dir.tmpdir, "stderr-#{@port}.tmp")
        end

        def cleanup
          FileUtils.remove_entry_secure wrapper_output_path if Pathname.new(wrapper_output_path).exist?
          FileUtils.remove_entry_secure stderr_output_path if Pathname.new(stderr_output_path).exist?
        end

        def add_override(override)
          @override_list << override
        end

        private

        def project_root
          File.expand_path(
            File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', '..')
          )
        end
      end
    end
  end
end
