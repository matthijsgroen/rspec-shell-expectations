require 'spec_helper'
include Rspec::Bash

describe 'StubbedEnv' do
  subject { create_stubbed_env }

  context '#execute(path, ...)' do
    describe 'running a file with non-existing commands' do
      it 'exits with an error' do
        `command1 "foo bar" 2>&1`
        expect($CHILD_STATUS.exitstatus).not_to eq 0
      end

      context 'with stubbed environment' do

        it 'exits with an error' do
          subject.execute_inline 'command1 "foo bar" 2>&1'
          expect($CHILD_STATUS.exitstatus).not_to eq 0
        end

        context 'with a stubbed command' do
          before do
            subject.stub_command('command1')
          end

          it 'exits with status code 0' do
            _, _, exitcode = subject.execute_inline 'command1 "foo bar" 2>&1'
            expect(exitcode.exitstatus).to eq 0
          end
        end
      end
    end
  end
end
