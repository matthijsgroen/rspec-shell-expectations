require 'spec_helper'
include Rspec::Bash::Wrapper

describe 'BashWrapper' do
  let(:server_port) { 4000 }
  subject { BashWrapper.new(server_port) }

  context '#wrap_script' do
    let(:script) do
      'echo hello world'
    end
    it 'creates a new script that wraps the passed in one' do
      wrapped_script = subject.wrap_script(script)
      expect(wrapped_script).to eql File.join(Dir.tmpdir, "wrapper-#{server_port}.sh")
    end
  end
  context '#cleanup' do
    it 'cleans up its wrapper and stderr files' do
      existing_file = double(File)
      allow(existing_file).to receive(:exist?)
        .and_return true
      allow(Pathname).to receive(:new)
        .with(File.join(Dir.tmpdir, "wrapper-#{server_port}.sh"))
        .and_return(existing_file)
      allow(Pathname).to receive(:new)
        .with(File.join(Dir.tmpdir, "stderr-#{server_port}.tmp"))
        .and_return(existing_file)

      expect(FileUtils).to receive(:remove_entry_secure)
        .with(File.join(Dir.tmpdir, "wrapper-#{server_port}.sh"))
      expect(FileUtils).to receive(:remove_entry_secure)
        .with(File.join(Dir.tmpdir, "stderr-#{server_port}.tmp"))

      subject.cleanup
    end
  end
end
