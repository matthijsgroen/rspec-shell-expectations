require 'spec_helper'

describe 'CallLog' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }
  let!(:first_command) { stubbed_env.stub_command('first_command') }

  context '#stdin' do
    context 'when given multiple command calls' do
      before(:each) do
        stubbed_env.execute_inline(
          <<-multiline_script
              echo -n 'first_call' | first_command first_argument second_argument
              echo -n 'second_call' | first_command first_argument second_argument third_argument
              first_command first_argument second_argument third_argument fourth_argument
        multiline_script
        )
      end

      it 'matches for implied anything matches' do
        expect(first_command.stdin).to eql 'first_call'
      end

      it 'does not match for non-matches' do
        expect(first_command.with_args('first_argument').stdin).to be nil
      end

      it 'matches for exact matches' do
        expect(first_command
          .with_args('first_argument', 'second_argument').stdin).to eql 'first_call'
      end

      it 'matches for anything matches' do
        expect(first_command
          .with_args(anything, anything, 'third_argument').stdin).to eql 'second_call'
      end

      it 'is blank for cases where no stdin was passed' do
        expect(first_command
          .with_args(anything, anything, 'third_argument', 'fourth_argument').stdin).to be_empty
      end

      it 'matches for any_args matches' do
        expect(first_command
          .with_args(any_args).stdin).to eql 'first_call'
      end

      it 'matches for other types of RSpec::Mock::ArgumentMatcher matches' do
        expect(first_command
          .with_args(instance_of(String), instance_of(String)).stdin).to eql 'first_call'
      end

      it 'matches for regex matches' do
        expect(first_command
          .with_args(/f..st_argument/, /se..nd_argument/, /.*/).stdin).to eql 'second_call'
      end
    end
  end
end
