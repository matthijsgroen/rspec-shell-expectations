# Rspec::Shell::Expectations
[![Build Status](https://travis-ci.org/matthijsgroen/rspec-shell-expectations.png?branch=master)](https://travis-ci.org/matthijsgroen/rspec-shell-expectations)
[![Gem Version](https://badge.fury.io/rb/rspec-shell-expectations.svg)](http://badge.fury.io/rb/rspec-shell-expectations)
[![Code Climate](https://codeclimate.com/github/matthijsgroen/rspec-shell-expectations/badges/gpa.svg)](https://codeclimate.com/github/matthijsgroen/rspec-shell-expectations)

Run your shell script in a mocked environment to test its behaviour
using RSpec.

## Features
- Test bash functions, entire scripts and inline scripts
- Stub shell commands and their exitstatus and outputs
- Partial mocks of functions
- Control exit status codes
- Control multiple outputs (through STDOUT, STDERR or files)
- Verify STDIN, STDOUT, STDERR
- Verify if command is called
- Verify command is called with specific arguments
- Verify arguments of command were called in correct sequence
- Verify command with specific arguments was called correct number of times

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-shell-expectations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-shell-expectations


You can setup rspec-shell-expectations globally for your spec suite:

in `spec_helper.rb`:

```ruby
  require 'rspec/shell/expectations'

  RSpec.configure do |c|
    c.include Rspec::Shell::Expectations
  end
```

## Usage

see specs in *spec/integration* folder:

### Running script through stubbed env:

```ruby
  require 'rspec/shell/expectations'

  describe 'my shell script' do
    include Rspec::Shell::Expectations

    let(:stubbed_env) { create_stubbed_env }

    it 'runs the script' do
      stdout, stderr, status = stubbed_env.execute(
        'my-shell-script.sh',
        { 'SOME_OPTIONAL' => 'env vars' }
      )
      expect(status.exitstatus).to eq 0
    end
  end
```

### Stubbing commands:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  let!(:bundle) { stubbed_env.stub_command('bundle') }

  it 'is stubbed' do
    stubbed_env.execute 'my-script.sh'
    expect(bundle).to be_called_with_arguments('install)
  end
```

### Changing exitstatus of stubs:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  before do
    stubbed_env.stub_command('rake').returns_exitstatus(5)
    stubbed_env.stub_command('rake').with_args('spec').returns_exitstatus(3)
  end
```

### Stubbing output:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  let(:rake_stub) { stubbed_env.stub_command 'rake' }
  before do
    rake_stub.outputs('informative message', to: :stdout)
      .outputs('error message', to: :stderr)
      .outputs('log contents', to: 'logfile.log')
      .outputs('converted result', to: ['prefix-', :arg2, '.txt'])
    # last one creates 'prefix-foo.txt' when called as 'rake convert foo'
  end
```

### Verifying stdin:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  let(:cat_stub) { stubbed_env.stub_command 'cat' }
  let(:mail_stub) { stubbed_env.stub_command 'mail' }
  it 'verifies stdin' do
    stubbed_env.execute_script 'script.sh'
    expect(cat_stub.stdin).to eql 'hello'
    expect(mail_stub.with_args('-s', 'hello').stdin).to eql 'world'
  end
```
### Test entire script

```ruby
let(:stubbed_env) { Rspec::Shell::Expectations::StubbedEnv.new }
stubbed_env.execute('./path/to/script.sh')
```

### Test specific function

```ruby
let(:stubbed_env) { Rspec::Shell::Expectations::StubbedEnv.new }
stubbed_env.stub_command('overridden_function')
stubbed_env.execute_function(
    './path/to/script.sh',
    'overridden_function'
)

```

### Test inline script

```ruby
let(:stubbed_env) { create_stubbed_env }
stubbed_env.stub_command('stubbed_command')
stubbed_env.execute_inline(<<-multiline_script
    stubbed_command first_argument second_argument
    multiline_script
)

```
### Check that mock was called with specific arguments

```ruby
describe 'be_called_with_arguments' do
  include Rspec::Shell::Expectations
  let(:stubbed_env) { create_stubbed_env }

  context 'with a command' do
    context 'and no chain calls' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
          stubbed_command first_argument second_argument
        multiline_script
        )
      end
      it 'correctly identifies the called arguments' do
        expect(@command).to be_called_with_arguments('first_argument', 'second_argument')
      end
      it 'correctly identifies the called arguments' do
        # The sequence 'first_argument', 'second_argument' starting at position 0
        expect(@command).to be_called_with_arguments('first_argument', 'second_argument').at_position(0)
      end
    end
  end
end
```

### Check that mock was called a certain number of times
```ruby
context 'and the times chain call' do
  before(:each) do
    @command = stubbed_env.stub_command('stubbed_command')
    @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
      stubbed_command duplicated_argument once_called_argument
      stubbed_command duplicated_argument
    multiline_script
    )
  end
  it 'matches when arguments are called twice' do
    expect(@command).to be_called_with_arguments('duplicated_argument').times(2)
  end
  it 'matches when argument is called once' do
    expect(@command).to be_called_with_arguments('once_called_argument').times(1)
  end
  it 'matches when argument combination is called once' do
    expect(@command).to be_called_with_arguments('duplicated_argument', 'once_called_argument').times(1)
  end
end
```

## More examples

see the *spec/integration* folder

## Supported ruby versions

Ruby 2+, no JRuby, due to issues with `Open3.capture3`

## Contributing

1. Fork it ( https://github.com/matthijsgroen/rspec-shell-expectations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
