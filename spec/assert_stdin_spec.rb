require 'English'
require 'rspec/shell/expectations'

describe 'Assert stdin' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:command1_stub) { stubbed_env.stub_command('command1') }

  let(:script) do
    <<-SCRIPT
      echo "foo bar" | command1
      echo "baz" | command1 'hello'
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

  describe '#stdin' do
    it 'returns the stdin' do
      subject
      expect(command1_stub.stdin).to match 'foo bar'
    end

    context 'with arguments' do
      it 'returns the stdin' do
        subject
        expect(command1_stub.with_args('hello').stdin).to match 'baz'
      end
    end
  end
end
