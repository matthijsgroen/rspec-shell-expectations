require 'spec_helper'

describe 'edge_cases.sh' do

  let(:stubbed_env) { create_stubbed_env }

  context('with multiple sub-command calls') do
    before(:each) do
      @apt = stubbed_env.stub_command('apt-get')
      @apt_install = @apt.with_args('install')
      @apt_remove = @apt.with_args('remove')

      @stdout, @stderr, @status = stubbed_env.execute(
          './edge_cases.sh'
      )
    end
    it 'returns no exit code' do
      expect(@stderr).to eq ''
      expect(@status.exitstatus).to eq 0
    end

    it 'calls apt-get install package_a' do
      expect(@apt_install).to be_called_with_arguments('package_a')
    end

    it 'calls apt-get remove package_b' do
      expect(@apt_remove).to be_called_with_arguments('package_b').at_position(0)
    end

    it 'calls apt-get install <anything> package_z>' do
      expect(@apt_install).to be_called_with_arguments('package_z').at_position(-2)
    end

    it 'calls apt-get remove <anything> package_y>' do
      expect(@apt_remove).to be_called_with_arguments('package_y').at_position(1)
    end

    it 'calls apt-get install <something> package_z package_x' do
      expect(@apt_install).to be_called_with_arguments('package_z','package_x').at_position(-2)
    end

    it 'does not call apt-get install package_b' do
      expect(@apt_install).to_not be_called_with_arguments('package_b')
    end

    it 'does not call apt-get remove package_a' do
      expect(@apt_remove).to_not be_called_with_arguments('package_a')
    end

    it 'does not call apt-get install package_y' do
      expect(@apt_install).to_not be_called_with_arguments('package_y').at_position(1)
    end

    it 'does not call apt-get remove package_z' do
      expect(@apt_remove).to_not be_called_with_arguments('package_z').at_position(-1)
    end

    it 'does not exactly call apt-get install package_a package_x' do
      expect(@apt_install).to_not be_called_with_arguments('package_a', 'package_x')
    end

    it 'does not call apt-get install package_z package_x <something>' do
      expect(@apt_install).to_not be_called_with_arguments('package_z', 'package_x').at_position(0)
    end
  end
  context('with lengthy sub-command sequences') do
    before(:each) do
      @apt = stubbed_env.stub_command('apt-get')
      @apt_install = @apt.with_args('install', '-f', '-q')
      @apt_remove = @apt.with_args('remove', '--purge')

      @stdout, @stderr, @status = stubbed_env.execute(
          './edge_cases.sh'
      )
    end
    it 'returns no exit code' do
      expect(@stderr).to eq ''
      expect(@status.exitstatus).to eq 0
    end

    it 'calls apt-get install -f -q package_a package_d' do
      expect(@apt_install).to be_called_with_arguments('package_a', 'package_d')
    end

    it 'calls apt-get remove --purge package_b package_c' do
      expect(@apt_remove).to be_called_with_arguments('package_b', 'package_c')
    end

    it 'calls apt-get install -f -q <anything> package_d' do
      expect(@apt_install).to be_called_with_arguments('package_d')
    end

    it 'calls apt-get remove --purge <last position> package_c' do
      expect(@apt_remove).to be_called_with_arguments('package_c').at_position(-1)
    end

    it 'does not call apt-get install -f -q package_b package_c' do
      expect(@apt_install).to_not be_called_with_arguments('package_b', 'package_c')
    end

    it 'does not call apt-get remove --purge package_a package_d' do
      expect(@apt_remove).to_not be_called_with_arguments('package_a', 'package_d')
    end
  end
end