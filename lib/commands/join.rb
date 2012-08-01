require 'enzyme'
require 'commands/config'

module Join extend self

  def run()
    # --skip-resources
    # --skip-production
    ARGV.each { |x| raise UnknownOption.new(x) if x.start_with?("-") }
    project_name = ARGV.shift
    ARGV.each { |x| raise UnknownArgument.new(x) }

    raise ArgumentMissing.new("project_name") unless project_name

    join(project_name)
  end

  def join(project_name)
    raise SyncServerRequired.new unless $system_settings.sync_server.exists
    raise SettingMissing.new("projects_directory") unless $settings.projects_directory
    raise SettingMissing.new("sync.projects_directory") unless $settings.sync.projects_directory
    raise SettingMissing.new("short_name") unless $settings.short_name

    local_directory = "#{$settings.projects_directory}/#{project_name}"
    remote_directory = "#{$system_settings.sync_server.path}/#{$settings.sync.projects_directory}/#{project_name}"

    # If the local project directory already exists, raise an error.
    raise ProjectAlreadyExists.new(local_directory) if File.directory?(local_directory)

    # If the remote project directory doesn't exists, raise an error.
    raise CannotFindProject.new(remote_directory) unless File.directory?(remote_directory)

    puts "Joining the '#{project_name}' project at '#{local_directory}'..."

    # Clone the resources and production directories.
    system "git clone -q #{remote_directory} #{local_directory}"
    print "."
    system "cd #{local_directory}; git checkout -q master;"
    print "."
    system "git clone -q #{remote_directory}/resources #{local_directory}/resources"
    print "."
    system "cd #{local_directory}/resources; git checkout -q master;"
    print "."
    system "git clone -q #{remote_directory}/production #{local_directory}/production"
    print "."
    system "cd #{local_directory}/production; git checkout -q master;"
    print "."

    # Create the user's production directory unless it's already there.
    system "mkdir #{local_directory}/production/#{$settings.short_name}" unless File.directory?("#{local_directory}/production/#{$settings.short_name}")
    puts

    puts "Done."
  end

end

Enzyme.register('join', Join) do
  puts "#{$format.bold}SYNOPSIS#{$format.normal}"
  puts "       enzyme join <project_name>"
  puts
  puts "#{$format.bold}DESCRIPTION#{$format.normal}"
  puts "       Joins a project by creatinga local version of a project from the sync server."
  puts
  puts "#{$format.bold}EXAMPLES#{$format.normal}"
  puts "       Joining a project called 'abc':"
  puts
  puts "               $ enzyme join abc"
  puts "               Joining the 'abc' project at '/Volumes/Shared/Projects/abc'..."
  puts "               ......"
  puts "               Done."
end
