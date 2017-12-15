require 'spec_helper'
include Rspec::Bash

describe 'BashWrapper' do
  context '.main' do
    before(:all) do
      stubbed_env = create_stubbed_env

      first_command = <<-multiline_script
        function first_command {
          echo 'first_command called'
        }
        readonly -f first_command
      multiline_script
      second_command = <<-multiline_script
        function second_command {
          echo 'second_command called' >&2
        }
      multiline_script

      subject = BashWrapper.new(4000)
      subject.add_override(first_command)
      subject.add_override(second_command)
      script_path = subject.wrap_script(
        <<-multiline_script
        function first_command {
          echo 'overridden'
        }
        first_command
        second_command
        multiline_script
      )
      @stdout, @stderr, @status = stubbed_env.execute(script_path)
    end

    it 'exits with a 0 exit code by default' do
      expect(@status.exitstatus).to eql 0
    end

    it 'injects the first_command override' do
      expect(@stdout.chomp).to eql 'first_command called'
    end

    it 'injects the second_command override (and omits a readonly error for first_command)' do
      expect(@stderr.chomp).to eql 'second_command called'
    end
  end
end
