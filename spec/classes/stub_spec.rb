require 'English'
require 'rspec/bash'
require 'yaml'

describe 'bin/stub' do
  let(:subject_path) { File.expand_path('stub', "#{File.dirname(__FILE__)}/../../bin") }
  let(:stub_call_pathname) { instance_double('Pathname') }
  let(:stub_config_pathname) { instance_double('Pathname') }
  let(:stub_call_file) { StringIO.new }

  before(:each) do
    allow(stub_call_pathname).to receive(:open).with('a').and_yield(stub_call_file)
    allow(stub_config_pathname).to receive(:exist?)
    allow_any_instance_of(Pathname).to receive(:join).with('stub_calls.yml').and_return(stub_call_pathname)
    allow_any_instance_of(Pathname).to receive(:join).with('stub_stub.yml').and_return(stub_config_pathname)
    allow_any_instance_of(Kernel).to receive(:exit)
  end

  context 'when called multiple times from a non-tty session' do
    before(:each) do
      allow(STDIN).to receive(:tty?).and_return(false)
    end
    context 'with different combinations of STDIN and arguments' do
      let(:stub_call_log) do
        allow(ARGV).to receive(:each)
        allow(STDIN).to receive(:read).and_return('')
        load subject_path

        allow(ARGV).to receive(:each)
        allow(STDIN).to receive(:read).and_return("dog\ncat\n")
        load subject_path

        allow(ARGV).to receive(:each).and_yield('first_argument').and_yield('second_argument')
        allow(STDIN).to receive(:read).and_return('')
        load subject_path

        allow(ARGV).to receive(:each).and_yield('first_argument').and_yield('second_argument')
        allow(STDIN).to receive(:read).and_return("dog\ncat\n")
        load subject_path

        YAML.load(stub_call_file.string)
      end

      it 'logs a blank STDIN for the first call' do
        expect(stub_call_log[0]['stdin']).to be_empty
      end

      it 'logs no arguments for the first call' do
        expect(stub_call_log[0]['args']).to be_nil
      end

      it 'logs some STDIN for the second call' do
        expect(stub_call_log[1]['stdin']).to eql "dog\ncat\n"
      end

      it 'logs no arguments for the second call' do
        expect(stub_call_log[1]['args']).to be_nil
      end

      it 'logs a blank STDIN for the third call' do
        expect(stub_call_log[2]['stdin']).to be_empty
      end

      it 'logs some arguments for the third call' do
        expect(stub_call_log[2]['args']).to eql %w(first_argument second_argument)
      end

      it 'logs some STDIN for the fourth call' do
        expect(stub_call_log[3]['stdin']).to eql "dog\ncat\n"
      end

      it 'logs some arguments for the fourth call' do
        expect(stub_call_log[3]['args']).to eql %w(first_argument second_argument)
      end
    end
  end
end