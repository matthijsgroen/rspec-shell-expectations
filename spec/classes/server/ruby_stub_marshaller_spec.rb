require 'spec_helper'
include Rspec::Bash

describe 'RubyStubMarshaller' do
  subject { RubyStubMarshaller.new }

  context('#unmarshal') do
    it('uses the built-in marshal library to unmarshal the data') do
      allow(Marshal).to receive(:load)
        .with('message_to_unmarshal')
        .and_return(message: 'unmarshalled')

      expect(subject.unmarshal('message_to_unmarshal'))
        .to eql(message: 'unmarshalled')
    end
  end
  context('#marshal') do
    it('uses the built-in marshal library to marshal the data') do
      allow(Marshal).to receive(:dump)
        .with(message: 'unmarshalled')
        .and_return('marshalled_message')

      expect(subject.marshal(message: 'unmarshalled'))
        .to eql('marshalled_message')
    end
  end
end
