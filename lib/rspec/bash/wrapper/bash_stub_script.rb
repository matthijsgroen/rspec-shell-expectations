module Rspec
  module Bash
    class BashStubScript
      def self.path
        File.join(project_root, 'bin', 'bash_stub.sh')
      end

      def self.project_root
        File.expand_path(
          File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', '..')
        )
      end
    end
  end
end

