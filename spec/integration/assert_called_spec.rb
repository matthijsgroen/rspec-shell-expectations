require 'spec_helper'

describe 'Assert called' do
  include Rspec::Bash
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

    stubbed_env.execute script_path.to_s
  end

  after do
    script_path.delete
  end

  describe 'assert called' do
    it 'returns called status' do
      expect(first_command).to be_called
    end

    context 'assert with args' do
      it 'returns called status' do
        expect(first_command).to be_called_with_arguments('foo bar')
        expect(first_command).to be_called_with_arguments(anything)
        expect(first_command).not_to be_called_with_arguments('foot')
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
