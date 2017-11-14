module Rspec
  module Bash
    class RubyStubFunction
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
        "#{stub_path} #{@name} #{@port} \"${@}\""
      end

      def to_s
        <<-multiline_string
        #{header}
        #{body}
        #{footer}
        multiline_string
      end

      def stub_path
        File.join(project_root, 'bin', 'ruby_stub.rb')
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
