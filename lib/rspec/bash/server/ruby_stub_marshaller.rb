module Rspec
  module Bash
    class RubyStubMarshaller
      def unmarshal(message_to_unmarshal)
        Marshal.load(message_to_unmarshal)
      end

      def marshal(object_to_marshal)
        Marshal.dump(object_to_marshal)
      end
    end
  end
end
