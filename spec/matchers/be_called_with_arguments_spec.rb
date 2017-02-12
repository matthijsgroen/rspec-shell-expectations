require 'spec_helper'

describe 'be_called_with_arguments' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }

  context 'with a command' do
    context 'and no chain calls' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(
          <<-multiline_script
            stubbed_command first_argument second_argument
          multiline_script
        )
      end
      it 'correctly identifies the called arguments' do
        expect(@command).to be_called_with_arguments('first_argument', 'second_argument')
      end
      it 'correctly matches when wildcard is used for first argument' do
        expect(@command).to be_called_with_arguments(anything, 'second_argument')
      end
      it 'correctly matches when wildcard is used for second argument' do
        expect(@command).to be_called_with_arguments('first_argument', anything)
      end
      it 'correctly matches when wildcard is used for all arguments' do
        expect(@command).to be_called_with_arguments(anything, anything)
      end

      it 'displays the diff between what was called and what was expected' do
        begin
          expect(@command).to be_called_with_arguments('not_first_argument', 'second_argument')
        rescue RSpec::Expectations::ExpectationNotMetError => rex
          expected_error_string = <<-multiline_string
Expected stubbed_command to be called with arguments ["not_first_argument", "second_argument"]

Expected Calls:
stubbed_command not_first_argument second_argument

Actual Calls:
stubbed_command first_argument second_argument
stubbed_command third_argument fourth_argument
multiline_string
          expect(rex.message.uncolorize).to eql expected_error_string
        end
      end

      it 'displays the diff between what was called and what was expected (negative case)' do
        begin
          expect(@command).to_not be_called_with_arguments('first_argument', 'second_argument')
        rescue RSpec::Expectations::ExpectationNotMetError => rex
          expected_error_string = 'Expected stubbed_command not to be ' \
            'called with arguments ["first_argument", "second_argument"]'
          expect(rex.message.uncolorize).to eql expected_error_string
        end
      end
    end
    context 'and the times chain call' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(
          <<-multiline_script
            stubbed_command duplicated_argument once_called_argument
            stubbed_command duplicated_argument irrelevant_argument
          multiline_script
        )
      end
      it 'matches when arguments are called twice' do
        expect(@command).to be_called_with_arguments('duplicated_argument', anything).times(2)
      end
      it 'matches when argument is called once' do
        expect(@command).to be_called_with_arguments(anything, 'once_called_argument').times(1)
      end
      it 'matches when argument combination is called once' do
        expect(@command)
          .to be_called_with_arguments('duplicated_argument', 'once_called_argument')
          .times(1)
      end
      it 'matches when argument is not called' do
        expect(@command).to_not be_called_with_arguments('not_called_argument').times(1)
      end
    end
  end
end
