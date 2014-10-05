require 'English'
require 'rspec/shell/expectations'

describe 'Change exitstatus' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }

  subject do
    stubbed_env.execute 'spec/fixtures/simple_script.sh'
  end

  describe 'default exitstatus' do
    it 'is 0' do
      subject
      expect($CHILD_STATUS.exitstatus).to eq 0
    end
  end

  describe 'changing exitstatus' do
    before do
      command1_stub.returns_exitstatus(4)
    end

    it 'returns the stubbed exitstatus' do
      subject
      expect($CHILD_STATUS.exitstatus).to eq 4
    end

    context 'with specific args only' do
      before do
        command1_stub.with_args('foo bar').returns_exitstatus(2)
        command1_stub.with_args('bar').returns_exitstatus(6)
      end

      it 'returns the stubbed exitstatus' do
        subject
        expect($CHILD_STATUS.exitstatus).to eq 2
      end
    end
  end
end
