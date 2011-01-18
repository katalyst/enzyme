require 'yaml'
require 'hash'
require 'settings'

# Default settings.
config = {
  :github => {
    :user => `git config --global github.user`.rstrip,
    :token => `git config --global github.token`.rstrip
  }
}
# Global settings.
config = config.deep_merge(YAML.load_file("#{ENV['HOME']}/.enzyme.yml")) if File.exist?("#{ENV['HOME']}/.enzyme.yml")
# Project settings.
config = config.deep_merge(YAML.load_file("./.enzyme.yml")) if File.exist?("./.enzyme.yml")

# Global settings object.
$settings = Settings.new(config)

# Global flag for full stacktraces.
$trace_errors = ARGV.delete('--trace')

# Version number.
$version = "0.1.0"