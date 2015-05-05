require 'English'
require 'rspec/shell/expectations'

describe 'StubbedEnv' do
  include Rspec::Shell::Expectations

  describe 'creating a stubbed env' do
    it 'extends the PATH with the stubbed folder first' do
      expect { create_stubbed_env }.to change { ENV['PATH'] }
    end

    it 'creates a folder to place the stubbed commands in' do
      env = create_stubbed_env
      expect(Pathname.new(env.dir)).to exist
      expect(Pathname.new(env.dir)).to be_directory
    end
  end

  describe '#cleanup' do
    it 'restores the environment variable PATH' do
      original_path = ENV['PATH']
      env = create_stubbed_env

      expect { env.cleanup }.to change { ENV['PATH'] }.to original_path
    end

    it 'removes the folder with stubbed commands' do
      env = create_stubbed_env
      env.cleanup
      expect(Pathname.new(env.dir)).not_to exist
    end
  end
end
