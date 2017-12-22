RSpec.shared_examples 'manage a :temp_directory' do
  let(:temp_directory) { Dir.mktmpdir }
  after(:each) do
    FileUtils.remove_entry_secure temp_directory
  end
end
