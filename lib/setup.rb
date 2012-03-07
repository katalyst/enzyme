require 'yaml'
require 'hash'
require 'string'

# Global formatiing helpers.
$format = {}
$format.bold = `tput bold`
$format.normal = `tput sgr0`

# System settings.
$system_settings                            = {}
$system_settings.config                     = {}
$system_settings.config.global              = {}
$system_settings.config.global.exists       = false
$system_settings.config.global.path         = "#{ENV['HOME']}/.enzyme.yml"
$system_settings.config.organisation        = {}
$system_settings.config.organisation.exists = false
$system_settings.config.organisation.path   = nil
$system_settings.config.project             = {}
$system_settings.config.project.exists      = false
$system_settings.config.project.path        = "./.enzyme.yml"
$system_settings.sync_server                = {}
$system_settings.sync_server.exists         = false
$system_settings.sync_server.skip           = !!ARGV.delete('--skip-sync-server')
$system_settings.trace_errors               = !!ARGV.delete('--trace')
$system_settings.version                    = File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))

# User configurable settings.
$settings                         = {}
$settings.enzyme_version          = nil
$settings.github                  = {}
$settings.github.user             = `git config --global github.user`.rstrip
$settings.github.token            = `git config --global github.token`.rstrip
$settings.project_name            = nil
$settings.projects_directory      = nil
$settings.short_name              = nil
$settings.sync                    = {}
$settings.sync.host_name          = nil
$settings.sync.projects_directory = nil
$settings.sync.share_name         = nil

# Global settings.
if File.exist?($system_settings.config.global.path)
  # Note the global config file's existence.
  $system_settings.config.global.exists = true
  $settings = $settings.deep_merge(YAML.load_file($system_settings.config.global.path) || {})
end

# Organisation settings.
if !$system_settings.sync_server.skip && $settings.sync.host_name && $settings.sync.share_name

  afp_url = "afp://#{$settings.sync.host_name}._afpovertcp._tcp.local/#{$settings.sync.share_name}"
  volume_path = "/Volumes/#{$settings.sync.share_name}"

  # Set the organisation config file's path.
  $system_settings.config.organisation.path = "/Volumes/#{$settings.sync.share_name}/.enzyme.yml"

  # Mount the sync server if it isn't already there.
  unless File.directory?(volume_path)
    `mkdir #{volume_path}`
    `mount -t afp #{afp_url} #{volume_path} > /dev/null` # > /dev/null is to suppress output
    `rm -r \"/Volumes/#{$settings.sync.share_name}\"` if $? != 0
  end

  # If the volume has been mounted.
  if File.directory?(volume_path)
    # Note the sync_server's existence.
    $system_settings.sync_server.exists = true
    # If the organisation config file doesn't exist yet, create it.
    `touch #{$system_settings.config.organisation.path}` unless File.exist?($system_settings.config.organisation.path)
    # Note the organisation config file's existence.
    $system_settings.config.organisation.exists = true
    # Merge the organisation settings.
    $settings = $settings.deep_merge(YAML.load_file($system_settings.config.organisation.path) || {})
    # Merge the global settings again (they have a higher priority).
    $settings = $settings.deep_merge(YAML.load_file($system_settings.config.global.path) || {}) if $system_settings.config.global.exists
  end

end

# Project settings.
if File.exist?($system_settings.config.project.path)
  # Note the project config file's existence.
  $system_settings.config.project.exists = true
  $settings = $settings.deep_merge(YAML.load_file($system_settings.config.project.path) || {})
end
