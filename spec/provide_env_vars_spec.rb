require 'English'
require 'rspec/shell/expectations'

describe 'Provide environment vars' do
  include Rspec::Shell::Expectations
  let(:script) do
    <<-SCRIPT
      echo $SOME_ENV_VAR
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

  let(:stubbed_env) { create_stubbed_env }

  it 'exits with an error' do
    o, _e, _s = stubbed_env.execute(
      script_path,
      'SOME_ENV_VAR' => 'SekretCredential'
    )
    expect(o).to eql "SekretCredential\n"
  end
end
