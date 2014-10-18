require 'English'
require 'rspec/shell/expectations'

describe 'Assert called' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }
  let!(:rake) { stubbed_env.stub_command('bundle').with_args('exec', 'rake') }

  let(:script) do
    <<-SCRIPT
      bundle exec rake foo:bar
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
      expect(rake.with_args('foo:bar')).to be_called
      expect(rake.with_args('foo')).not_to be_called
    end
  end
end
