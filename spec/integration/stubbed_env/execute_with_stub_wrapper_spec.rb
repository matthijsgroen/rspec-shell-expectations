require 'English'
require 'rspec/bash'

describe 'StubbedEnv' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }
  let!(:grep_mock) { stubbed_env.stub_command('grep') }
  let!(:ls_mock) { stubbed_env.stub_command('ls') }

  context '#execute(<commands that are in stub wrapper>, ...)' do
    it 'does not call the grep command' do
      stubbed_env.execute_inline('exit 0')

      expect(grep_mock).to_not be_called
    end

    it 'does not call the ls command' do
      stubbed_env.execute_inline('exit 0')

      expect(ls_mock).to_not be_called
    end
  end
end
