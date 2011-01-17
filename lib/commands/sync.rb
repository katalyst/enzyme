require 'enzyme'

module Sync extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    project_name = ARGV.shift || $settings.project_name

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