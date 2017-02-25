require 'yaml'

module Rspec
  module Bash
    class CallConfiguration
      attr_reader :command
      attr_accessor :configuration

      def initialize(config_path, command)
        @config_path = config_path
        @configuration = []
        @command = command
      end

      def set_exitcode(statuscode, args = [])
        current_conf = create_or_get_conf(args)
        current_conf[:statuscode] = statuscode
      end

      def add_output(content, target, args = [])
        current_conf = create_or_get_conf(args)
        current_conf[:outputs] << {
          content: content,
          target: target
        }
      end

      def write
        @config_path.open('w') do |conf_file|
          conf_file.write @configuration.to_yaml
        end
      end

      def read
        return @configuration unless @configuration.empty?
        @config_path.open('r') do |conf_file|
          YAML.load(conf_file.read)
        end
      end

      private

      def create_or_get_conf(args)
        new_conf = {
          args: args,
          statuscode: 0,
          outputs: []
        }
        current_conf = @configuration.select do |conf|
          conf[:args] == args
        end

        @configuration << new_conf if current_conf.empty?
        current_conf.first || new_conf
      end
    end
  end
end
