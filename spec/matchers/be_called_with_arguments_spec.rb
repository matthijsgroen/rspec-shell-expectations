require 'English'
require 'rspec/shell/expectations'

describe 'be_called_with_arguments' do
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
        expect(@command_with_one_argument).to be_called_with_arguments('first_argument')
      end

      it 'confirms that an unpassed argument was nowhere in called command\'s argument list' do
        expect(@command_with_one_argument).to_not be_called_with_arguments('not_an_argument')
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
        expect(@command_with_two_arguments).to be_called_with_arguments('first_argument')
      end

      it 'confirms that the second argument was anywhere in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('second_argument')
      end

      it 'confirms that the two arguments were in order in the called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('first_argument', 'second_argument')
      end

      it 'confirms that an unpassed argument was nowhere in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arguments('not_an_argument')
      end
    end
    context 'and a command called with three arguments' do
      before(:each) do
        @command_with_three_arguments = stubbed_env.stub_command('command_with_three_arguments')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_three_arguments first_argument second_argument third_argument
        multiline_script
        )
      end

      it 'confirms that the first argument was anywhere in called command\'s argument list' do
        expect(@command_with_three_arguments).to be_called_with_arguments('first_argument')
      end

      it 'confirms that the second argument was anywhere in called command\'s argument list' do
        expect(@command_with_three_arguments).to be_called_with_arguments('second_argument')
      end

      it 'confirms that two contiguous arguments were in order in the called command\'s argument list' do
        expect(@command_with_three_arguments).to be_called_with_arguments('second_argument', 'third_argument')
      end

      it 'confirms that three contiguous arguments were in order in the called command\'s argument list' do
        expect(@command_with_three_arguments).to be_called_with_arguments('first_argument', 'second_argument', 'third_argument')
      end

      it 'confirms that two non-contiguous arguments were not in order in the called command\'s argument list' do
        expect(@command_with_three_arguments).to_not be_called_with_arguments('first_argument', 'third_argument')
      end

      it 'confirms that an unpassed argument was nowhere in called command\'s argument list' do
        expect(@command_with_three_arguments).to_not be_called_with_arguments('not_an_argument')
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

      it 'confirms that the argument was at the specified position in the command\'s argument list' do
        expect(@command_with_one_argument).to be_called_with_arguments('first_argument').at_position(-1)
      end

      it 'confirms that an unpassed argument was not at the specified position in called command\'s argument list' do
        expect(@command_with_one_argument).to_not be_called_with_arguments('not_an_argument').at_position(-1)
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
        expect(@command_with_two_arguments).to be_called_with_arguments('first_argument').at_position(-2)
      end

      it 'confirms that the second argument was at the last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('second_argument').at_position(-1)
      end

      it 'confirms that the first argument was at the last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arguments('first_argument').at_position(-1)
      end

      it 'confirms that the second argument was not at the second to last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arguments('second_argument').at_position(-2)
      end

      it 'confirms that the two arguments were in order at the position in the called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('first_argument', 'second_argument').at_position(-2)
      end
    end
    context 'and a command called with three arguments' do
      before(:each) do
        @command_with_two_arguments = stubbed_env.stub_command('command_with_two_arguments')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
          command_with_two_arguments first_argument second_argument third_argument
        multiline_script
        )
      end

      it 'confirms that the first argument was at the third to last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('first_argument').at_position(-3)
      end

      it 'confirms that the second argument was at the seonc to last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('second_argument').at_position(-2)
      end

      it 'confirms that the third argument was at the last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('third_argument').at_position(-1)
      end

      it 'confirms that the first argument was at the last position in called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arguments('first_argument').at_position(-1)
      end

      it 'confirms that the three arguments were in order at the position in the called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('first_argument', 'second_argument', 'third_argument').at_position(-3)
      end

      it 'confirms that the first two arguments were in order at the position in the called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('first_argument', 'second_argument').at_position(-3)
      end

      it 'confirms that the last two arguments were in order at the position in the called command\'s argument list' do
        expect(@command_with_two_arguments).to be_called_with_arguments('second_argument', 'third_argument').at_position(-2)
      end

      it 'confirms that the last two arguments were in not order at the first position in the called command\'s argument list' do
        expect(@command_with_two_arguments).to_not be_called_with_arguments('second_argument', 'third_argument').at_position(-3)
      end
    end
  end
end