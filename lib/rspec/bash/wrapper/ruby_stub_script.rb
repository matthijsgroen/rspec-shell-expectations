module Rspec
  module Bash
    class RubyStubScript
      def self.path
        File.join(project_root, 'bin', 'ruby_stub.rb')
      end

      def self.project_root
        File.expand_path(
          File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..', '..')
        )
      end
    end
  end
end
