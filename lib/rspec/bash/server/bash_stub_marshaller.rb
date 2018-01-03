require 'sparsify'
require 'json'

module Rspec
  module Bash
    class BashStubMarshaller
      def unmarshal(message_to_unmarshal)
        object_to_unflatten = JSON.parse(message_to_unmarshal)
        unflattened_object = Sparsify.unsparse(object_to_unflatten)
        JSON.parse(JSON.dump(unflattened_object), symbolize_names: true)
      end

      def marshal(object_to_marshal)
        object_to_dump = Sparsify.sparse(object_to_marshal, sparse_array: true)
        JSON.pretty_generate(object_to_dump, indent: '', space: '')
      end
    end
  end
end
