require 'rspec/bash'
include Rspec::Bash

describe 'StubbedEnv' do
  subject { create_stubbed_env }
  let!(:grep_mock) { subject.stub_command('grep') }

  context '#execute(<commands that are in stub wrapper>, ...)' do
    it 'does not call the grep command' do
      subject.execute_inline('exit 0')

      expect(grep_mock).to_not be_called
    end
  end
end
