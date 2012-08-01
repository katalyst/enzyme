require 'yaml'
require 'hash'
require 'string'
require 'errors'

# Global formatting helpers.
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
$system_settings.sync_server.path           = nil
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
system "touch #{$system_settings.config.global.path}" unless File.exist?($system_settings.config.global.path)
$system_settings.config.global.exists = true
$settings = $settings.deep_merge(YAML.load_file($system_settings.config.global.path) || {})

# Sync server.
if !$system_settings.sync_server.skip && $settings.sync.host_name && $settings.sync.share_name

  afp_url = "afp://#{$settings.sync.host_name}._afpovertcp._tcp.local/#{$settings.sync.share_name}"

  # Set the sync server's path.
  $system_settings.sync_server.path = "/Volumes/#{$settings.sync.share_name}"
  # Set the organisation config file's path.
  $system_settings.config.organisation.path = "/Volumes/#{$settings.sync.share_name}/.enzyme.yml"

  # Mount the sync server if it isn't already there.
  unless File.directory?($system_settings.sync_server.path)
    `mkdir #{$system_settings.sync_server.path}`
    `mount -t afp #{afp_url} #{$system_settings.sync_server.path} &> /dev/null`
    `rm -r \"/Volumes/#{$settings.sync.share_name}\"` if $? != 0
  end

  # If the volume has been mounted.
  if File.directory?($system_settings.sync_server.path)
    # Note the sync_server's existence.
    $system_settings.sync_server.exists = true

    # Organisation settings.
    system "touch #{$system_settings.config.organisation.path}" unless File.exist?($system_settings.config.organisation.path)
    $system_settings.config.organisation.exists = true
  end

  # Organisation settings.
  if $system_settings.sync_server.exists && $system_settings.config.organisation.exists
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
