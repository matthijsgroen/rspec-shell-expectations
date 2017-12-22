[![Stories in Ready](https://badge.waffle.io/mdurban/rspec-bash.png?label=ready&title=Ready)](http://waffle.io/mdurban/rspec-bash)
[![Build Status](https://travis-ci.org/mdurban/rspec-bash.svg?branch=master)](https://travis-ci.org/mdurban/rspec-bash)
[![Dependency Status](https://gemnasium.com/badges/github.com/mdurban/rspec-bash.svg)](https://gemnasium.com/github.com/mdurban/rspec-bash)

# Rspec::Bash

Run your shell script in a mocked environment to test its behavior using RSpec.

## Features
- Test bash functions, entire scripts and inline scripts
- Stub shell commands and their exitstatus and outputs
- Partial mocks of functions
- Control multiple outputs (through STDOUT, STDERR or files)
- Verify STDIN, STDOUT, STDERR
- Verify command was called with specific argument sequence
- Verify command was called correct number of times
- Supports RSpec matchers

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-bash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-bash


You can setup rspec-bash globally for your spec suite:

in `spec_helper.rb`:

```ruby
  require 'rspec/bash'

  RSpec.configure do |c|
    c.include Rspec::Bash
  end
```

## Usage

see specs in *spec/integration* folder:

### Running script through stubbed env:

```ruby
  require 'rspec/bash'

  describe 'my shell script' do
    include Rspec::Bash

    let(:stubbed_env) { create_stubbed_env }

    it 'runs the script' do
      stdout, stderr, status = stubbed_env.execute(
        'my-shell-script.sh',
        { 'OPTIONAL_ENV' => 'env vars' }
      )
      expect(status.exitstatus).to eq 0
    end
  end
```

### Choosing a stub type
The stubbed functions/commands for the test runner were traditionally built with ruby. A faster alternative stub, written in bash, has recently been introduced, and is the current default. This can be configured, however, as shown.
For ruby:
```ruby
let(:stubbed_env) { create_stubbed_env(StubbedEnv::RUBY_STUB) }
```
For bash (default, if not provided):
```ruby
let(:stubbed_env) { create_stubbed_env(StubbedEnv::BASH_STUB) }
```

Via environment variable:
```bash
export RSPEC_BASH_STUB_TYPE=ruby_stub
# <run your tests here>
...
```

### Stubbing commands:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  let!(:bundle) { stubbed_env.stub_command('bundle') }
  let!(:absolute_command) { stubbed_env.stub_command('/path/to/bundle') }
  let!(:relative_command) { stubbed_env.stub_command('./path/to/bundle') }

  it 'is stubbed' do
    stubbed_env.execute 'my-script.sh'
    expect(bundle).to be_called_with_arguments('install')
    expect(absolute_command).to be_called_with_arguments('hello')
    expect(relative_command).to be_called_with_arguments('world')
  end
```

### Changing exitstatus of stubs:

```ruby
  stubbed_env.stub_command('rake').returns_exitstatus(5)
```

```ruby
  stubbed_env.stub_command('rake').with_args('spec').returns_exitstatus(3)
```

### Stubbing output:

```ruby
  let(:rake_stub) { stubbed_env.stub_command('rake') }

  rake_stub.outputs('informative message', to: :stdout)
    .outputs('error message', to: :stderr)
    .outputs('log contents', to: 'logfile.log')
    # creates 'prefix-foo.txt' when called as 'rake convert foo'
    .outputs('converted result', to: ['prefix-', :arg2, '.txt'])
```

### Verifying stdin:

```ruby
  let(:stubbed_env) { create_stubbed_env }

  it 'verifies stdin with no args' do
    cat_stub = stubbed_env.stub_command('cat')

    expect(cat_stub.stdin).to eql 'hello'
  end

  it 'verifies stdin with args' do
    mail_stub = stubbed_env.stub_command('mail')

    expect(mail_stub.with_args('-s', 'hello').stdin).to eql 'world'
  end
```

### Test entire script, specific function or inline script

```ruby
stubbed_env.execute('./path/to/script.sh')
```

```ruby
stubbed_env.execute_function(
    './path/to/script.sh',
    'overridden_function'
)
```

```ruby
stubbed_env.execute_inline(<<-multiline_script
    stubbed_command first_argument second_argument
    multiline_script
)
```

### Check that mock was called with specific arguments

```ruby
stubbed_env.execute_inline(<<-multiline_script
  stubbed_command first_argument second_argument
 multiline_script
)

it 'correctly identifies the called arguments' do
  expect(@command).to be_called_with_arguments('first_argument', 'second_argument')
end
```

### Check that mock was not called with any arguments

```ruby
expect(@command).to be_called_with_no_arguments
```

### Check that mock was called a certain number of times
```ruby
  @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
    stubbed_command duplicated_argument
    stubbed_command duplicated_argument
    stubbed_command once_called_argument
  multiline_script

  expect(@command).to be_called_with_arguments('duplicated_argument').times(2)
  expect(@command).to be_called_with_arguments('once_called_argument').times(1)
end
```

### Supports RSpec matchers
```ruby
it 'stub call with a wildcard used for an argument' do
  grep_mock = stubbed_env.stub_command('grep')
  grep_mock.with_args('-r', anything).outputs('output from grep')

  expect(command).to be_called_with_arguments('output from grep')
end
```

```ruby
it 'correctly matches when wildcard is used for arguments' do
  expect(@command).to be_called_with_arguments(anything, 'second_argument', anything)
end
```

```ruby
it 'matches any arguments' do
  expect(@command).to be_called_with_arguments
end
```

```ruby
it 'matches all arguments' do
  expect(@command).to be_called_with_arguments(any_args)
end
```

```ruby
it 'matches any String argument' do
  expect(@command).to be_called_with_arguments(instance_of(String))
end
```

```ruby
it 'matches using regexp' do
  expect(@command).to be_called_with_arguments(/s..arg/)
end
```

### Pitfalls and known issues

- Use `$BASH_SOURCE[0]` instead of `$0` in your Bash scripts when trying to get the directory that your called script is in. This is a good habit to use when writing scripts as `$0` should rarely be used.
`$0` also has some ramifications when using this gem; it will always be `bash` and will not be the name of the script.
Please see https://www.gnu.org/software/bash/manual/bashref.html#Positional-Parameters for more information on `$0`

- The `execute_function()` method is recommended to be used only when testing Bash libraries. This is because it needs to source the entire file to run the function under test, so any executable code in the script will be run even if it is outside of the function being tested

- The current form of stub injection does not allow for stubs to be picked up by other commands. Ex. `xargs stubbed_command` will result in the `stubbed_command` not being found. There is a pending issue for this.
## More examples

see the *spec/integration* folder

## Supported ruby versions

Ruby 2+, no JRuby, due to issues with `Open3.capture3`

## Contributing

1. Fork it (https://github.com/mdurban/rspec-bash)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
