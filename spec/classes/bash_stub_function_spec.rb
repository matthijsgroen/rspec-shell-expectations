require 'spec_helper'
include Rspec::Bash

describe 'StubFunction' do
  subject { BashStubFunction.new('first_command', 55_555) }

  context '#body' do
    it 'uses a shell script that calls the bash_stub.sh script with the command and port' do
      expect(subject.body).to match(Regexp.escape('/bin/bash_stub.sh first_command 55555 "${@}"'))
    end
  end
end
