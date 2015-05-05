# Rspec::Shell::Expectations
[![Build Status](https://travis-ci.org/matthijsgroen/rspec-shell-expectations.png?branch=master)](https://travis-ci.org/matthijsgroen/rspec-shell-expectations)
[![Gem Version](https://badge.fury.io/rb/rspec-shell-expectations.svg)](http://badge.fury.io/rb/rspec-shell-expectations)
[![Code Climate](https://codeclimate.com/github/matthijsgroen/rspec-shell-expectations/badges/gpa.svg)](https://codeclimate.com/github/matthijsgroen/rspec-shell-expectations)

Run your shell script in a mocked environment to test its behaviour
using RSpec.

## Features

- Setup a fake shell environment that has preference in exucing commands
  (highest path value)
- Stub shell commands in this environment
- Control multiple outputs (through STDOUT, STDERR or files)
- Control exit status codes
- Set different configurations based on command line arguments
- Verify if command is called
- Verify arguments command is called with
- Verify STDIN


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

see specs in `spec/` folder:

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
  let(:bundle) { stubbed_env.stub_command('bundle') }
  let(:rake) { bundle.with_args('exec', 'rake') }

  it 'is stubbed' do
    stubbed_env.execute 'my-script.sh'
    expect(rake.with_args('test')).to be_called
    expect(bundle.with_args('install)).to be_called
  end
```

### Changing exitstatus:

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

### Verifying called:

```ruby
  let(:stubbed_env) { create_stubbed_env }
  let(:rake_stub) { stubbed_env.stub_command 'rake' }
  it 'verifies called' do
    stubbed_env.execute_script 'script.sh'

    expect(rake_stub).to be_called
    expect(rake_stub.with_args('spec')).to be_called
    expect(rake_stub.with_args('features')).not_to be_called
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

## More examples

see the *features* and *spec* folder

## Supported ruby versions

Ruby 2+, no JRuby, due to issues with `Open3.capture3`

## Contributing

1. Fork it ( https://github.com/matthijsgroen/rspec-shell-expectations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
