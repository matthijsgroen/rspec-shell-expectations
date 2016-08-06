require 'English'
require 'rspec/shell/expectations'

describe 'Assert called' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:first_command) { stubbed_env.stub_command('first_command') }

  let(:script) do
    <<-SCRIPT
      first_command "foo bar"
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
      expect(first_command).to be_called
    end

    context 'assert with args' do
      it 'returns called status' do
        subject
        expect(first_command.with_args('foo bar')).to be_called
        expect(first_command.with_args('foo')).not_to be_called
      end
    end

    describe 'assertion message' do
      it 'provides a helpful message' do
        expect(first_command.inspect).to eql '<Stubbed "first_command">'
        expect(first_command.with_args('foo bar').inspect).to \
          eql '<Stubbed "first_command" args: "foo bar">'
      end
    end
  end
end
