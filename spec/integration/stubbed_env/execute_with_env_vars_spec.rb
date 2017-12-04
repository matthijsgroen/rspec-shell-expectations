require 'spec_helper'
include Rspec::Bash

describe 'StubbedEnv' do
  subject { create_stubbed_env }

  context '#execute(..., ENV => VARIABLES)' do

    it 'exits with an error' do
      stdout, = subject.execute_inline(
        'echo $SOME_ENV_VAR',
        'SOME_ENV_VAR' => 'SekretCredential'
      )
      expect(stdout).to eql "SekretCredential\n"
    end
  end
end
