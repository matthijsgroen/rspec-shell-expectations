require 'English'
require 'rspec/shell/expectations'

describe 'be_called_with_arg' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }

  context 'with no chain calls' do
    context 'and a command called with one argument' do
      before(:each) do
        @command_with_one_argument = stubbed_env.stub_command('command_with_one_argument')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_one_argument first_argument
        multiline_script
        )
      end

      it 'confirms that the argument was anywhere in called command\'s argument list' do
        expect(@command_with_one_argument).to be_called_with_arg('first_argument')
      end

      it 'confirms that an unpassed argument was nowhere in called command\'s argument list' do
        expect(@command_with_one_argument).to_not be_called_with_arg('not_an_argument')
      end
    end
    context 'and a command called with two arguments' do
      before(:each) do
        @command_with_two_arguments = stubbed_env.stub_command('command_with_two_arguments')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_two_arguments first_argument second_argument
        multiline_script
        )
      end

      it 'confirms that the first argument was anywhere in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arg('first_argument')
      end

      it 'confirms that the second argument was anywhere in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arg('second_argument')
      end

      it 'confirms that an unpassed argument was nowhere in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arg('not_an_argument')
      end
    end
  end

  context 'with the at_position chain added' do
    context 'and a command called with one argument' do
      before(:each) do
        @command_with_one_argument = stubbed_env.stub_command('command_with_one_argument')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_one_argument first_argument
        multiline_script
        )
      end

      it 'confirms that the argument was at the last position in called command\'s argument list' do
        expect(@command_with_one_argument).to be_called_with_arg('first_argument').at_position(-1)
      end

      it 'confirms that an unpassed argument was not in the last positions of called command\'s argument list' do
        expect(@command_with_one_argument).to_not be_called_with_arg('not_an_argument').at_position(-1)
      end
    end
    context 'and a command called with two arguments' do
      before(:each) do
        @command_with_two_arguments = stubbed_env.stub_command('command_with_two_arguments')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_two_arguments first_argument second_argument
        multiline_script
        )
      end

      it 'confirms that the first argument was at the second to last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arg('first_argument').at_position(-2)
      end

      it 'confirms that the second argument was at the last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arg('second_argument').at_position(-1)
      end

      it 'confirms that the first argument was at the last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arg('first_argument').at_position(-1)
      end

      it 'confirms that the second argument was not at the second to last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arg('second_argument').at_position(-2)
      end
    end
  end

  context 'with the with_flag chain added' do
    context 'and a command called with one flagged argument' do
      before(:each) do
        @command_with_one_argument = stubbed_env.stub_command('command_with_one_argument')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_one_argument --first-argument first_argument
        multiline_script
        )
      end

      it 'confirms that the argument was with the specified flag in called command\'s argument list' do
        expect(@command_with_one_argument).to be_called_with_arg('first_argument').with_flag('--first-argument')
      end

      it 'confirms that an unpassed argument was not with the specified flag in called command\'s argument list' do
        expect(@command_with_one_argument).to_not be_called_with_arg('not_an_argument').with_flag('--first-argument')
      end
    end
    context 'and a command called with two flagged arguments' do
      before(:each) do
        @command_with_two_arguments = stubbed_env.stub_command('command_with_two_arguments')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_two_arguments --first-argument first_argument --second-argument second_argument
        multiline_script
        )
      end

      it 'confirms that the first argument was with the first flag in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arg('first_argument').with_flag('--first-argument')
      end

      it 'confirms that the second argument was with the second flag in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arg('second_argument').with_flag('--second-argument')
      end

      it 'confirms that the first argument was not with the second flag in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arg('first_argument').with_flag('--second-argument')
      end

      it 'confirms that the second argument was not with the first flag in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arg('second_argument').with_flag('--first-argument')
      end
    end
  end
end