require 'spec_helper'

describe 'StubbedEnv' do
  include Rspec::Bash

  context '#execute(..., ENV => VARIABLES)' do
    let(:stubbed_env) { create_stubbed_env }

    it 'exits with an error' do
      stdout, = stubbed_env.execute_inline(
        'echo $SOME_ENV_VAR',
        'SOME_ENV_VAR' => 'SekretCredential'
      )
      expect(stdout).to eql "SekretCredential\n"
    end
  end
end
