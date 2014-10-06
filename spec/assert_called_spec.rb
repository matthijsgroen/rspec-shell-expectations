require 'English'
require 'rspec/shell/expectations'

describe 'Assert called' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }

  subject do
    stubbed_env.execute 'spec/fixtures/simple_script.sh'
  end

  describe 'assert called' do
    it 'returns called status' do
      subject
      expect(command1_stub).to be_called
    end

    context 'assert with args' do
      it 'returns called status' do
        subject
        expect(command1_stub.with_args('foo bar')).to be_called
        expect(command1_stub.with_args('foo')).not_to be_called
      end
    end
  end
end
