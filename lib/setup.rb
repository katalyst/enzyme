require 'yaml'
require 'hash'

# Make sure there's a global settings file.
system "touch \"#{ENV['HOME']}/.enzyme.yml\"" unless File.exist?("#{ENV['HOME']}/.enzyme.yml")

# Default settings.
$settings = {
  'github' => {
    'user' => `git config --global github.user`.rstrip,
    'token' => `git config --global github.token`.rstrip
  }
}

# Global settings.
$settings = $settings.deep_merge(YAML.load_file("#{ENV['HOME']}/.enzyme.yml") || {}) if File.exist?("#{ENV['HOME']}/.enzyme.yml")

# Organisation settings.
begin
  # Mount the sync server if it isn't already there.
  unless File.directory?("/Volumes/#{$settings.sync.share_name}")
    `mkdir \"/Volumes/#{$settings.sync.share_name}\"`
    `mount -t afp \"afp://#{$settings.sync.host_name}._afpovertcp._tcp.local/#{$settings.sync.share_name}\" \"/Volumes/#{$settings.sync.share_name}\" > /dev/null`
  end
  # If the sync server has a config file, add it to the settings.
  if File.exist?("/Volumes/#{$settings.sync.share_name}/.enzyme.yml")
    # Merge the organisation settings.
    $settings = $settings.deep_merge(YAML.load_file("/Volumes/#{$settings.sync.share_name}/.enzyme.yml") || {})
    # Merge the global settings again.
    $settings = $settings.deep_merge(YAML.load_file("#{ENV['HOME']}/.enzyme.yml") || {}) if File.exist?("#{ENV['HOME']}/.enzyme.yml")
  end
rescue
  # TODO: Delete the mount directory if it was created, but the volume wasn't mounted.
end

# Project settings.
$settings = $settings.deep_merge(YAML.load_file("./.enzyme.yml") || {}) if File.exist?("./.enzyme.yml")

# Global flag for full stacktraces.
$trace_errors = ARGV.delete('--trace')

# Version number.
$version = File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))

# Global formatiing helpers.
$format = {}
$format.bold = `tput bold`
$format.normal = `tput sgr0`
