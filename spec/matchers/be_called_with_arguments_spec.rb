require 'English'
require 'rspec/shell/expectations'

describe 'be_called_with_arguments' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }

  context 'with basic commands (ex. git)' do
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

  context 'with commands that have sub-commands (ex. git pull)' do
    before(:each) do
      @command_with_sub_commands = stubbed_env.stub_command('command_with_sub_commands')
    end
    context 'with no chain calls' do
      context 'and multiple sub-commands are called' do
        before(:each) do
          @first_subcommand_of_command = @command_with_sub_commands.with_args('first_sub_command')
          @second_subcommand_of_command = @command_with_sub_commands.with_args('second_sub_command')
        end
        context 'with a single, different argument' do
          before(:each) do
            @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
              command_with_sub_commands first_sub_command first_sub_command_argument
              command_with_sub_commands second_sub_command second_sub_command_argument
            multiline_script
            )
          end

          it 'confirms that the first sub command argument was called on the command with sub-commands' do
            expect(@command_with_sub_commands).to be_called_with_arguments('first_sub_command_argument')
          end

          it 'confirms that the second sub command argument was called on the command with sub-commands' do
            expect(@command_with_sub_commands).to be_called_with_arguments('second_sub_command_argument')
          end

          it 'confirms that the first sub command argument was called on the first sub-command' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument')
          end

          it 'confirms that the second sub command argument was called on the second sub-command' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument')
          end

          it 'confirms that the second sub command argument was not called on the first sub-command' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument')
          end

          it 'confirms that the first sub command argument was not called on the second sub-command' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument')
          end
        end
        context 'with a two, different arguments' do
          before(:each) do
            @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
              command_with_sub_commands first_sub_command first_sub_command_argument_one first_sub_command_argument_two
              command_with_sub_commands second_sub_command second_sub_command_argument_one second_sub_command_argument_two
            multiline_script
            )
          end

          it 'confirms that the first sub command\'s second argument was called on the command with sub-commands' do
            expect(@command_with_sub_commands).to be_called_with_arguments('first_sub_command_argument_two')
          end

          it 'confirms that the second sub command\'s second argument was called on the command with sub-commands' do
            expect(@command_with_sub_commands).to be_called_with_arguments('second_sub_command_argument_two')
          end

          it 'confirms that the first sub command\'s second argument was called on the first sub-command' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument_two')
          end

          it 'confirms that the second sub command\'s second argument was called on the second sub-command' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument_two')
          end

          it 'confirms that the second sub command\'s second argument was not called on the first sub-command' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument_two')
          end

          it 'confirms that the first sub command\'s second argument was not called on the second sub-command' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument_two')
          end

          it 'confirms that the first sub command\'s first and second arguments were called on the first sub-command' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_two')
          end

          it 'confirms that the second sub command\'s first and second arguments were called on the second sub-command' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument_one', 'second_sub_command_argument_two')
          end
        end
        context 'with a three, different arguments' do
          before(:each) do
            @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
              command_with_sub_commands first_sub_command first_sub_command_argument_one first_sub_command_argument_two first_sub_command_argument_three
              command_with_sub_commands second_sub_command second_sub_command_argument_one second_sub_command_argument_two second_sub_command_argument_three
            multiline_script
            )
          end

          it 'confirms that the first sub command\'s first, second and third arguments were called on the first sub-command' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_two', 'first_sub_command_argument_three')
          end

          it 'confirms that the second sub command\'s first, second and third arguments were called on the second sub-command' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument_one', 'second_sub_command_argument_two', 'second_sub_command_argument_three')
          end

          it 'confirms that the first sub command\'s non-contiguous arguments were not called on the first sub-command' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_three')
          end

          it 'confirms that the second sub command\'s non-contiguous arguments were not called on the second sub-command' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument_one', 'second_sub_command_argument_three')
          end

          it 'confirms that the first sub command\'s contiguous arguments were not called on the second sub-command' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_two')
          end

          it 'confirms that the second sub command\'s contiguous arguments were not called on the second sub-command' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument_two', 'second_sub_command_argument_three')
          end
        end
      end
    end
    context 'with the at_position chain added' do
      context 'and multiple sub-commands are called' do
        before(:each) do
          @first_subcommand_of_command = @command_with_sub_commands.with_args('first_sub_command')
          @second_subcommand_of_command = @command_with_sub_commands.with_args('second_sub_command')
        end
        context 'with a single, different argument' do
          before(:each) do
            @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
              command_with_sub_commands first_sub_command first_sub_command_argument
              command_with_sub_commands second_sub_command second_sub_command_argument
            multiline_script
            )
          end

          it 'confirms that the first sub command argument was called on the command with sub-commands at the second position' do
            expect(@command_with_sub_commands).to be_called_with_arguments('first_sub_command_argument').at_position(1)
          end

          it 'confirms that the second sub command argument was called on the command with sub-commands at the second position' do
            expect(@command_with_sub_commands).to be_called_with_arguments('second_sub_command_argument').at_position(1)
          end

          it 'confirms that the first sub command argument was called on the first sub-command' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument').at_position(0)
          end

          it 'confirms that the second sub command argument was called on the second sub-command' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument').at_position(0)
          end

          it 'confirms that the second sub command argument was not called on the first sub-command' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument').at_position(0)
          end

          it 'confirms that the first sub command argument was not called on the second sub-command' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument').at_position(0)
          end
        end
        context 'with a two, different arguments' do
          before(:each) do
            @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
              command_with_sub_commands first_sub_command first_sub_command_argument_one first_sub_command_argument_two
              command_with_sub_commands second_sub_command second_sub_command_argument_one second_sub_command_argument_two
            multiline_script
            )
          end

          it 'confirms that the first sub command\'s second argument was called on the command with sub-commands at the third position' do
            expect(@command_with_sub_commands).to be_called_with_arguments('first_sub_command_argument_two').at_position(2)
          end

          it 'confirms that the second sub command\'s second argument was called on the command with sub-commands at the third position' do
            expect(@command_with_sub_commands).to be_called_with_arguments('second_sub_command_argument_two').at_position(2)
          end

          it 'confirms that the first sub command\'s second argument was called on the first sub-command at the second position' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument_two').at_position(1)
          end

          it 'confirms that the second sub command\'s second argument was called on the second sub-command at the second position' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument_two').at_position(1)
          end

          it 'confirms that the second sub command\'s second argument was not called on the first sub-command at the second position' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument_two').at_position(1)
          end

          it 'confirms that the first sub command\'s second argument was not called on the second sub-command at the second position' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument_two').at_position(1)
          end

          it 'confirms that the first sub command\'s first and second arguments were called on the first sub-command at the second position' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_two').at_position(0)
          end

          it 'confirms that the second sub command\'s first and second arguments were called on the second sub-command at the second position' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument_one', 'second_sub_command_argument_two').at_position(0)
          end
        end
        context 'with a three, different arguments' do
          before(:each) do
            @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute(<<-multiline_script
              command_with_sub_commands first_sub_command first_sub_command_argument_one first_sub_command_argument_two first_sub_command_argument_three
              command_with_sub_commands second_sub_command second_sub_command_argument_one second_sub_command_argument_two second_sub_command_argument_three
            multiline_script
            )
          end

          it 'confirms that the first sub command\'s arguments were called on the command with sub-commands at the second position' do
            expect(@command_with_sub_commands).to be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_two', 'first_sub_command_argument_three').at_position(1)
          end

          it 'confirms that the second sub command\'s arguments were called on the command with sub-commands at the second position' do
            expect(@command_with_sub_commands).to be_called_with_arguments('second_sub_command_argument_one', 'second_sub_command_argument_two', 'second_sub_command_argument_three').at_position(1)
          end

          it 'confirms that the first sub command\'s first, second and third arguments were called on the first sub-command at the first position' do
            expect(@first_subcommand_of_command).to be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_two', 'first_sub_command_argument_three').at_position(0)
          end

          it 'confirms that the second sub command\'s first, second and third arguments were called on the second sub-command at the first position' do
            expect(@second_subcommand_of_command).to be_called_with_arguments('second_sub_command_argument_one', 'second_sub_command_argument_two', 'second_sub_command_argument_three').at_position(0)
          end

          it 'confirms that the first sub command\'s non-contiguous arguments were not called on the first sub-command at the first position' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_three').at_position(0)
          end

          it 'confirms that the second sub command\'s non-contiguous arguments were not called on the second sub-command at the first position' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument_one', 'second_sub_command_argument_three').at_position(0)
          end

          it 'confirms that the first sub command\'s contiguous arguments were not called on the second sub-command at the first position' do
            expect(@second_subcommand_of_command).to_not be_called_with_arguments('first_sub_command_argument_one', 'first_sub_command_argument_two').at_position(0)
          end

          it 'confirms that the second sub command\'s contiguous arguments were not called on the second sub-command at the second position' do
            expect(@first_subcommand_of_command).to_not be_called_with_arguments('second_sub_command_argument_two', 'second_sub_command_argument_three').at_position(1)
          end
        end
      end
    end
  end
end