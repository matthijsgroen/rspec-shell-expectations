require 'spec_helper'

describe 'CallLog' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }
  let!(:first_command) { stubbed_env.stub_command('first_command') }

  context '#called_with_args?' do
    context 'when given multiple command calls' do
      before(:each) do
        stubbed_env.execute_inline(
          <<-multiline_script
              first_command first_argument second_argument
              first_command first_argument second_argument third_argument
        multiline_script
        )
      end

      it 'matches for implied anything matches' do
        expect(first_command).to be_called_with_arguments
      end

      it 'does not match for non-matches' do
        expect(first_command).to_not be_called_with_arguments('first_argument')
      end

      it 'matches for exact matches' do
        expect(first_command).to be_called_with_arguments('first_argument', 'second_argument')
      end

      it 'matches for anything matches' do
        expect(first_command).to be_called_with_arguments(anything, anything, 'third_argument')
      end

      it 'matches for anyd_args matches' do
        expect(first_command).to be_called_with_arguments(any_args)
      end

      it 'matches for other types of RSpec::Mock::ArgumentMatcher matches' do
        expect(first_command).to be_called_with_arguments(instance_of(String), instance_of(String))
      end

      it 'matches for regex matches' do
        expect(first_command).to be_called_with_arguments(/f..st_argument/, /se..nd_argument/)
      end

      it 'displays the diff between what was called and what was expected' do
        begin
          expect(first_command).to be_called_with_arguments('not_first_argument', 'second_argument')
        rescue RSpec::Expectations::ExpectationNotMetError => rex
          expected_error_string = <<-multiline_string
Expected first_command to be called with arguments ["not_first_argument", "second_argument"]

Expected Calls:
first_command not_first_argument second_argument

Actual Calls:
first_command first_argument second_argument
first_command first_argument second_argument third_argument
          multiline_string
          expect(rex.message).to eql expected_error_string
        end
      end
      it 'displays the diff between what was called and what was not expected' do
        begin
          expect(first_command).to_not be_called_with_arguments('first_argument', 'second_argument')
        rescue RSpec::Expectations::ExpectationNotMetError => rex
          expected_error_string = <<-multiline_string
Expected first_command to not be called with arguments ["first_argument", "second_argument"]

Expected Omissions:
first_command first_argument second_argument

Actual Calls:
first_command first_argument second_argument
first_command first_argument second_argument third_argument
          multiline_string
          expect(rex.message).to eql expected_error_string
        end
      end
    end
  end
end
