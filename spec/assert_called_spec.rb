require 'English'
require 'rspec/shell/expectations'

describe 'Assert called' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }

  let(:script) do
    <<-SCRIPT
      command1 "foo bar"
    SCRIPT
  end
  let(:script_path) { Pathname.new '/tmp/test_script.sh' }

  before do
    script_path.open('w') { |f| f.puts script }
    script_path.chmod 0777
  end

  after do
    script_path.delete
  end

  subject do
    stubbed_env.execute script_path.to_s
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

    describe 'assertion message' do
      it 'provides a helpful message' do
        expect(command1_stub.inspect).to eql '<Stubbed "command1">'
        expect(command1_stub.with_args('foo bar').inspect).to \
          eql '<Stubbed "command1" args: "foo bar">'
      end
    end
  end
end
