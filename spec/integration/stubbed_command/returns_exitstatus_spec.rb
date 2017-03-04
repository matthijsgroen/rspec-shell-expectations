require 'spec_helper'

describe 'StubbedCommand' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }

  context '#returns_exitstatus' do
    context 'when given exit status to return' do
      let(:status) do
        _, _, status = stubbed_env.execute_inline('command1 first_argument second_argument')
        status.exitstatus
      end

      it 'exits with the appropriate exit code' do
        expect(status).to be 0
      end
    end

    context 'when given no args to match' do
      let(:status) do
        command1_stub
          .returns_exitstatus(100)
        _, _, status = stubbed_env.execute_inline('command1 first_argument second_argument')
        status.exitstatus
      end

      it 'exits with the appropriate exit code' do
        expect(status).to be 100
      end
    end

    context 'when given an exact argument match' do
      let(:status) do
        command1_stub
          .with_args('first_argument', 'second_argument')
          .returns_exitstatus(101)
        _, _, status = stubbed_env.execute_inline('command1 first_argument second_argument')
        status.exitstatus
      end

      it 'exits with the appropriate exit code' do
        expect(status).to be 101
      end
    end
    context 'when given an anything argument match' do
      let(:status) do
        command1_stub
          .with_args('first_argument', anything)
          .returns_exitstatus(102)
        _, _, status = stubbed_env.execute_inline('command1 first_argument second_argument')
        status.exitstatus
      end

      it 'exits with the appropriate exit code' do
        expect(status).to be 102
      end
    end
    context 'when given any_args argument match' do
      let(:status) do
        command1_stub
          .with_args(any_args)
          .returns_exitstatus(103)
        _, _, status = stubbed_env.execute_inline('command1 poglet piglet')
        status.exitstatus
      end

      it 'exits with the appropriate exit code' do
        expect(status).to be 103
      end
    end
    context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
      let(:status) do
        command1_stub
          .with_args(instance_of(String), instance_of(String))
          .returns_exitstatus(104)
        _, _, status = stubbed_env.execute_inline('command1 poglet 1')
        status.exitstatus
      end

      it 'exits with the appropriate exit code' do
        expect(status).to be 104
      end
    end
    context 'when given regex argument match' do
      let(:status) do
        command1_stub
          .with_args(/p.glet/, /p.glet/)
          .returns_exitstatus(105)
        _, _, status = stubbed_env.execute_inline('command1 poglet piglet')
        status.exitstatus
      end

      it 'exits with the appropriate exit code' do
        expect(status).to be 105
      end
    end
  end
end
