[![Stories in Ready](https://badge.waffle.io/mdurban/rspec-bash.png?label=ready&title=Ready)](http://waffle.io/mdurban/rspec-bash)
[![Build Status](https://travis-ci.org/mdurban/rspec-bash.svg?branch=master)](https://travis-ci.org/mdurban/rspec-bash)

# Rspec::Bash

Run your shell script in a mocked environment to test its behavior using RSpec.

## Features
- Test bash functions, entire scripts and inline scripts
- Stub shell commands and their exitstatus and outputs
- Partial mocks of functions
- Control exit status codes
- Control multiple outputs (through STDOUT, STDERR or files)
- Verify STDIN, STDOUT, STDERR
- Verify if command is called
- Verify command is called with specific argument sequence
- Verify command was called correct number of times
- Supports RSpec "anything" wildcard matchers

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
    stubbed_env.execute 'script.sh'
    expect(cat_stub.stdin).to eql 'hello'
    expect(mail_stub.with_args('-s', 'hello').stdin).to eql 'world'
  end
```
### Test entire script

```ruby
let(:stubbed_env) { Rspec::Bash::StubbedEnv.new }
stubbed_env.execute('./path/to/script.sh')
```

### Test specific function

```ruby
let(:stubbed_env) { Rspec::Bash::StubbedEnv.new }
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
  include Rspec::Bash
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
    end
  end
end
```

### Check that mock was not called with any arguments

```ruby
@command = stubbed_env.stub_command('stubbed_command')
stubbed_env.execute_inline(<<-multiline_script
  stubbed_command
multiline_script

it 'correctly identifies that no arguments were called' do
  expect(@command).to be_called_with_no_arguments
end
```

### Check that mock was called a certain number of times
```ruby
context 'and the times chain call' do
  before(:each) do
    @command = stubbed_env.stub_command('stubbed_command')
    @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
      stubbed_command duplicated_argument
      stubbed_command duplicated_argument
      stubbed_command once_called_argument
    multiline_script
    )
  end
  it 'matches when arguments are called twice' do
    expect(@command).to be_called_with_arguments('duplicated_argument').times(2)
  end
  it 'matches when argument is called once' do
    expect(@command).to be_called_with_arguments('once_called_argument').times(1)
  end
end
```

### Use rspec "anything" wildcards for arguments you don't need to match exactly
```ruby
it 'correctly matches when wildcard is used for arguments' do
  expect(@command).to be_called_with_arguments(anything, 'second_argument', anything)
end
```

## More examples

see the *spec/integration* folder

## Supported ruby versions

Ruby 2+, no JRuby, due to issues with `Open3.capture3`

## Contributing

1. Fork it ( https://github.com/mdurban/rspec-bash )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
