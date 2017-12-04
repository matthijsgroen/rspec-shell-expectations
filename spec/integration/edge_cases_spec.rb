require 'rspec/bash'
include Rspec::Bash

describe 'scenarios where performance improvements break things' do
  let(:stubbed_env) { create_stubbed_env }

  context 'weird case where a docker flag argument gets removed' do
    let!(:docker) { stubbed_env.stub_command('docker') }
    before do
      stubbed_env.execute_inline(<<-multiline_script
          docker run \
            --rm \
            -i \
            --env HADOOP_USER_NAME \
            --env CLIENT_CONF_URL \
            xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
            hadoop fs -test -e  hdfs:///xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        multiline_script
      )
    end
    it 'should not remove the -e flag from the command log' do
      expect(docker).to be_called_with_arguments(
        'run',
        '--rm',
        '-i',
        '--env', 'HADOOP_USER_NAME',
        '--env', 'CLIENT_CONF_URL',
        'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
        'hadoop', 'fs', '-test', '-e', 'hdfs:///xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      )
    end
  end
end
