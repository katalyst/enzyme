require 'enzyme'

module Sync extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    project_name = ARGV.shift || $settings.project_name

    unless project_name
      Enzyme.error("No project name specified. Ensure you're in the project's directory or set it specifically. Run `enzyme help sync` for help.")
      return
    end

    unless $settings.sync.share_name
      Enzyme.error("The `sync.share_name` setting is not set. Set it using `enzyme config sync.share_name \"Share Name\"`.")
      return
    end

    unless $settings.sync.host
      Enzyme.error("The `sync.host` setting is not set. Set it using `enzyme config sync.host \"Host._afpovertcp._tcp.local\"`.")
      return
    end

    unless $settings.sync.projects_directory
      Enzyme.error("The `sync.projects_directory` setting is not set. Set it using `enzyme config sync.projects_directory \"My Projects Directory\"`.")
      return
    end

    unless $settings.sync.protected_directory
      Enzyme.error("The `sync.protected_directory` setting is not set. Set it using `enzyme config sync.protected_directory \"my_directory\"`.")
      return
    end

    unless $settings.sync.shared_directory
      Enzyme.error("The `sync.shared_directory` setting is not set. Set it using `enzyme config sync.shared_directory \"our_shared_directory\"`.")
      return
    end

    # Mount the network volume. Only works on OS X.
    system "mkdir \"/Volumes/#{$settings.sync.share_name}\""
    system "mount -t afp \"afp://#{$settings.sync.host}/#{$settings.sync.share_name}\" \"/Volumes/#{$settings.sync.share_name}\""
    system "mkdir \"/Volumes/#{$settings.sync.share_name}/#{$settings.sync.projects_directory}/#{project_name}\""
    # Pull.
    system "rsync -aH --stats -v -u --progress --exclude '#{$settings.sync.protected_directory}/**' \"/Volumes/#{$settings.sync.share_name}/#{$settings.sync.projects_directory}/#{project_name}/\" '#{$settings.projects_directory}/#{project_name}/resources/'"
    # Push.
    system "rsync -aH --stats -v -u --progress --include '*/' --include '#{$settings.sync.shared_directory}/**' --include '#{$settings.sync.protected_directory}/**' --exclude '*' '#{$settings.projects_directory}/#{project_name}/resources/' \"/Volumes/#{$settings.sync.share_name}/#{$settings.sync.projects_directory}/#{project_name}/\""
  end

end

Enzyme.register(Sync) do
  puts 'SYNC COMMAND'
  puts '--------------'
  puts ''
  puts '### SYNOPSIS'
  puts ''
  puts '    enzyme sync [project_name]'
  puts ''
  puts '### EXAMPLES'
  puts ''
  puts '    cd ~/Projects/my_project'
  puts '    enzyme sync'
  puts ''
  puts '    enzyme sync another_project'
  puts ''
end