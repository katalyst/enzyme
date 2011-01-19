require 'enzyme'

module Sync extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    project_name = ARGV.shift || $settings.project_name

    raise "No project name specified. Ensure you're in the project's directory or set it specifically. Run `enzyme help sync` for help." unless project_name
    raise "The #{project_name} project could not be found." unless File.exist?("#{$settings.projects_directory}/#{project_name}")
    raise "The `sync.share_name` setting is not set. Set it using `enzyme config sync.share_name \"Share Name\" --global`." unless $settings.sync.share_name
    raise "The `sync.host` setting is not set. Set it using `enzyme config sync.host \"Host._afpovertcp._tcp.local\" --global`." unless $settings.sync.host
    raise "The `sync.projects_directory` setting is not set. Set it using `enzyme config sync.projects_directory \"My Projects Directory\" --global`." unless $settings.sync.projects_directory
    raise "The `user` setting is not set. Set it using `enzyme config user \"my_directory\" --global`." unless $settings.user
    raise "The `sync.shared_directory` setting is not set. Set it using `enzyme config sync.shared_directory \"our_shared_directory\" --global`." unless $settings.sync.shared_directory

    # Mount the network volume. Only works on OS X.
    system "mkdir \"/Volumes/#{$settings.sync.share_name}\""
    system "mount -t afp \"afp://#{$settings.sync.host}/#{$settings.sync.share_name}\" \"/Volumes/#{$settings.sync.share_name}\""
    system "mkdir \"/Volumes/#{$settings.sync.share_name}/#{$settings.sync.projects_directory}/#{project_name}\""
    # Pull.
    system "rsync -aH --stats -v -u --progress --exclude '#{$settings.user}/**' \"/Volumes/#{$settings.sync.share_name}/#{$settings.sync.projects_directory}/#{project_name}/\" '#{$settings.projects_directory}/#{project_name}/resources/'"
    # Push.
    system "rsync -aH --stats -v -u --progress --include '*/' --include '#{$settings.sync.shared_directory}/**' --include '#{$settings.user}/**' --exclude '*' '#{$settings.projects_directory}/#{project_name}/resources/' \"/Volumes/#{$settings.sync.share_name}/#{$settings.sync.projects_directory}/#{project_name}/\""
  end

end

Enzyme.register(Sync) do
  puts 'SYNC COMMAND'
  puts '------------'
  puts ''
  puts '### SYNOPSIS'
  puts ''
  puts '    enzyme sync [<project_name>]'
  puts ''
  puts '### OPTIONS'
  puts ''
  puts '<project_name>'
  puts ':   The name of the project to sync. If the working directory is the root of a project this option does not need to be passed.'
  puts ''
  puts '### EXAMPLES'
  puts ''
  puts '    cd ~/Projects/my_project'
  puts '    enzyme sync'
  puts ''
  puts '    enzyme sync another_project'
  puts ''
end