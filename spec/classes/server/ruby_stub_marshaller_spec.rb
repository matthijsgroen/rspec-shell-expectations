require 'spec_helper'
include Rspec::Bash

describe 'RubyStubMarshaller' do
  subject { RubyStubMarshaller.new }

  context '#unmarshal' do
    before do
      allow(Marshal).to receive(:load)
        .with('message_to_unmarshal')
        .and_return(message: 'unmarshalled')
    end

    it 'uses the built-in marshal library to unmarshal the data' do
      expect(subject.unmarshal('message_to_unmarshal'))
        .to eql(message: 'unmarshalled')
    end
  end
  context '#marshal' do
    before do
      allow(Marshal).to receive(:dump)
        .with(message: 'unmarshalled')
        .and_return('marshalled_message')
    end

    it 'uses the built-in marshal library to marshal the data' do
      expect(subject.marshal(message: 'unmarshalled'))
        .to eql('marshalled_message')
    end
  end
end
