require 'spec_helper'

describe 'CallConfiguration' do
  let(:stubbed_env) { create_stubbed_env }
  include Rspec::Bash

  context '#set_exitcode' do
    context 'with any setup' do
      subject { Rspec::Bash::CallConfiguration.new(anything, anything) }

      context 'with no existing configuration' do
        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.configuration).to eql [
            {
              args: %w(first_argument second_argument),
              statuscode: 1,
              outputs: []
            }
          ]
        end
      end
      context 'with an existing, non-matching configuration' do
        before(:each) do
          subject.configuration = [
            {
              args: %w(first_argument),
              statuscode: 1,
              outputs: []
            }
          ]
        end
        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.configuration).to eql [
            {
              args: %w(first_argument),
              statuscode: 1,
              outputs: []
            },
            {

              args: %w(first_argument second_argument),
              statuscode: 1,
              outputs: []
            }
          ]
        end
      end
      context 'with an existing, matching configuration' do
        before(:each) do
          subject.configuration = [
            {
              args: %w(first_argument second_argument),
              statuscode: 2,
              outputs: []
            }
          ]
        end
        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.configuration).to eql [
            {

              args: %w(first_argument second_argument),
              statuscode: 1,
              outputs: []
            }
          ]
        end
      end
    end
  end
  context '#add_output' do
    context 'with any setup' do
      subject { Rspec::Bash::CallConfiguration.new(anything, anything) }

      context 'with no existing configuration' do
        it 'updates the outputs for the arguments passed in' do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
          expect(subject.configuration).to eql [
            {
              args: %w(first_argument second_argument),
              statuscode: 0,
              outputs: [
                {
                  target: :stderr,
                  content: 'new_content'
                }
              ]
            }
          ]
        end
      end
      context 'with an existing, non-matching configuration' do
        before(:each) do
          subject.configuration = [
            {
              args: %w(first_argument),
              statuscode: 1,
              outputs: [
                {
                  target: :stdout,
                  content: 'different_content'
                }
              ]
            }
          ]
        end
        it 'updates the outputs conf for the arguments passed in' do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
          expect(subject.configuration).to eql [
            {
              args: %w(first_argument),
              statuscode: 1,
              outputs: [
                {
                  target: :stdout,
                  content: 'different_content'
                }
              ]
            },
            {
              args: %w(first_argument second_argument),
              statuscode: 0,
              outputs: [
                {
                  target: :stderr,
                  content: 'new_content'
                }
              ]
            }
          ]
        end
      end
      context 'with an existing, matching configuration' do
        before(:each) do
          subject.configuration = [
            {
              args: %w(first_argument second_argument),
              statuscode: 1,
              outputs: [
                {
                  target: :stdout,
                  content: 'old_content'
                }
              ]
            }
          ]
        end
        it 'adds to the outputs conf for the arguments passed in' do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
          expect(subject.configuration).to eql [
            {
              args: %w(first_argument second_argument),
              statuscode: 1,
              outputs: [
                {
                  target: :stdout,
                  content: 'old_content'
                },
                {
                  target: :stderr,
                  content: 'new_content'
                }
              ]
            }
          ]
        end
      end
    end
  end
  context '#write' do
    context 'when there is no config_path' do
      subject { Rspec::Bash::CallConfiguration.new(nil, anything) }
      it 'raises an error' do
        expect { subject.write }.to raise_exception(NoMethodError)
      end
    end
    context 'when setup is valid' do
      let(:mock_conf_file) { instance_double(Pathname) }
      subject { Rspec::Bash::CallConfiguration.new(mock_conf_file, 'command_name') }

      before(:each) do
        subject.configuration = [{
          args: %w(first_argument second_argument),
          statuscode: 1,
          outputs: [
            {
              target: :stdout,
              content: 'old_content'
            },
            {
              target: :stderr,
              content: 'new_content'
            }
          ]
        }]
        allow(mock_conf_file).to receive(:open).with('w').and_yield(mock_conf_file)
      end

      it 'writes a YAML version of its configuration to the config file' do
        expect(mock_conf_file).to receive(:write).with(subject.configuration.to_yaml)
        subject.write
      end
    end
  end
  context '#read' do
    context 'when there is no config_path' do
      subject { Rspec::Bash::CallConfiguration.new(nil, anything) }
      it 'raises an error' do
        expect { subject.read }.to raise_exception(NoMethodError)
      end
    end
    context 'when setup is valid' do
      let(:mock_conf_file) { instance_double(Pathname) }
      subject { Rspec::Bash::CallConfiguration.new(mock_conf_file, 'command_name') }
      let(:conf) do
        [{
          args: %w(first_argument second_argument),
          statuscode: 1,
          outputs: [
            {
              target: :stdout,
              content: 'old_content'
            },
            {
              target: :stderr,
              content: 'new_content'
            }
          ]
        }]
      end
      context 'and no configuration exists' do
        before(:each) do
          allow(mock_conf_file).to receive(:read).and_return(conf.to_yaml)
          allow(mock_conf_file).to receive(:open).with('r').and_yield(mock_conf_file)
        end

        it 'reads out what was in its configuration file' do
          expect(subject.read).to eql conf
        end
      end
      context 'and configuration already exists' do
        before(:each) do
          subject.configuration = conf
        end

        it 'reads out what was in its configuration file' do
          expect(subject.read).to eql conf
        end
      end
    end
  end
end
