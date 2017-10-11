module Rspec
  module Bash
    class BashStubFunction
      def initialize(name, port)
        @name = name
        @port = port
      end

      def header
        "function #{@name} {"
      end

      def footer
        "}\nreadonly -f #{@name} &> /dev/null"
      end

      def body
        "#{BashStubFunction.stub_path} #{@name} #{@port} \"${@}\""
      end

      def self.stub_path
        File.join(project_root, 'bin', 'bash_stub.sh')
      end

      private

      def self.project_root
        File.expand_path(
          File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', '..')
        )
      end
    end
  end
end

