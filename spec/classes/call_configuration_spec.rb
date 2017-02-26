require 'spec_helper'

describe 'CallConfiguration' do
  let(:stubbed_env) { create_stubbed_env }
  include Rspec::Bash

  let(:mock_conf_file) { instance_double(Pathname) }
  before(:each) do
    allow(mock_conf_file).to receive(:open).with('w').and_yield(mock_conf_file)
    allow(mock_conf_file).to receive(:write).with(anything)
  end

  context '#set_exitcode' do
    context 'with any setup' do
      subject { Rspec::Bash::CallConfiguration.new(mock_conf_file, 'command_name') }

      context 'with no existing configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument second_argument),
              statuscode: 1,
              outputs: []
            }
          ]
        end

        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end

        it 'writes that configuration to its conf file' do
          expect(mock_conf_file).to receive(:write).with(expected_conf.to_yaml)
          subject.set_exitcode(1, %w(first_argument second_argument))
        end
      end
      context 'with an existing, non-matching configuration' do
        let(:expected_conf) do
          [
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
        before(:each) do
          subject.call_configuration = [
            {
              args: %w(first_argument),
              statuscode: 1,
              outputs: []
            }
          ]
        end
        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end

        it 'writes that configuration to its conf file' do
          expect(mock_conf_file).to receive(:write).with(expected_conf.to_yaml)
          subject.set_exitcode(1, %w(first_argument second_argument))
        end
      end
      context 'with an existing, matching configuration' do
        let(:expected_conf) do
          [
            {

              args: %w(first_argument second_argument),
              statuscode: 1,
              outputs: []
            }
          ]
        end
        before(:each) do
          subject.call_configuration = [
            {
              args: %w(first_argument second_argument),
              statuscode: 2,
              outputs: []
            }
          ]
        end

        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end

        it 'writes that configuration to its conf file' do
          expect(mock_conf_file).to receive(:write).with(expected_conf.to_yaml)
          subject.set_exitcode(1, %w(first_argument second_argument))
        end
      end
    end
    context 'with no config_path' do
      subject { Rspec::Bash::CallConfiguration.new(nil, anything) }
      it 'raises an error' do
        expect do
          subject.set_exitcode(1, %w(first_argument second_argument))
        end.to raise_exception(NoMethodError)
      end
    end
  end
  context '#add_output' do
    context 'with any setup' do
      subject { Rspec::Bash::CallConfiguration.new(mock_conf_file, 'command_name') }

      context 'with no existing configuration' do
        let(:expected_conf) do
          [
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
        it 'updates the outputs for the arguments passed in' do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end

        it 'writes that configuration to its conf file' do
          expect(mock_conf_file).to receive(:write).with(expected_conf.to_yaml)
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
        end
      end
      context 'with an existing, non-matching configuration' do
        let(:expected_conf) do
          [
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
        before(:each) do
          subject.call_configuration = [
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
          expect(subject.call_configuration).to eql expected_conf
        end

        it 'writes that configuration to its conf file' do
          expect(mock_conf_file).to receive(:write).with(expected_conf.to_yaml)
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
        end
      end
      context 'with an existing, matching configuration' do
        let(:expected_conf) do
          [
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
        before(:each) do
          subject.call_configuration = [
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
          expect(subject.call_configuration).to eql expected_conf
        end

        it 'writes that configuration to its conf file' do
          expect(mock_conf_file).to receive(:write).with(expected_conf.to_yaml)
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
        end
      end
    end
    context 'with no config_path' do
      subject { Rspec::Bash::CallConfiguration.new(nil, anything) }
      it 'raises an error' do
        expect do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
        end.to raise_exception(NoMethodError)
      end
    end
  end
  context '#call_configuration' do
    context 'when there is no config_path' do
      subject { Rspec::Bash::CallConfiguration.new(nil, anything) }
      it 'raises an error' do
        expect { subject.call_configuration }.to raise_exception(NoMethodError)
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
      context 'and no in-memory configuration exists' do
        before(:each) do
          allow(mock_conf_file).to receive(:read).and_return(conf.to_yaml)
          allow(mock_conf_file).to receive(:open).with('r').and_yield(mock_conf_file)
        end

        it 'reads out what was in its configuration file' do
          expect(subject.call_configuration).to eql conf
        end
      end
      context 'and an in-memory configuration already exists' do
        before(:each) do
          subject.call_configuration = conf
        end

        it 'reads out what was in its configuration file' do
          expect(subject.call_configuration).to eql conf
        end
      end
    end
  end
end
