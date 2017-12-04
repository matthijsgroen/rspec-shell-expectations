require 'spec_helper'
include Rspec::Bash

describe 'BashStubMarshaller' do
  subject { BashStubMarshaller.new }

  context '#unmarshal' do
    before do
      allow(JSON).to receive(:parse)
        .with('message_to_unmarshal')
        .and_return('message.child' => 'unmarshalled')
      allow(Sparsify).to receive(:unsparse)
        .with('message.child' => 'unmarshalled')
        .and_return(message: { child: 'unmarshalled' })
      allow(JSON).to receive(:parse)
        .with('{"message":{"child":"unmarshalled"}}', symbolize_names: true)
        .and_return(message: { child: 'unmarshalled' })
    end
    it 'uses the JSON and sparsify libraries to unflatten the data' do
      expect(subject.unmarshal('message_to_unmarshal'))
        .to eql(message: { child: 'unmarshalled' })
    end
  end
  context '#marshal' do
    before do
      allow(Sparsify).to receive(:sparse)
        .with({message: { child: 'unmarshalled' }}, sparse_array: true)
        .and_return(:'message.child' => 'unmarshalled')
      allow(JSON).to receive(:pretty_generate)
        .with({:'message.child' => 'unmarshalled'}, indent: '', space: '')
        .and_return("{\n\"message.child\":\"unmarshalled\"\n}")
    end
    it 'uses the JSON and sparsify libraries to flatten the data' do
      expect(subject.marshal(message: { child: 'unmarshalled' }))
        .to eql("{\n\"message.child\":\"unmarshalled\"\n}")
    end
  end
end
