require 'enzyme'
require 'commands/config'

module Join extend self

  def run()
    # --skip-resources
    # --skip-working
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

    # Clone the resources and working directories.
    system "git clone -q #{remote_directory} #{local_directory}"
    system "cd #{local_directory}; git checkout -q master;"
    system "git clone -q #{remote_directory}/resources #{local_directory}/resources"
    system "cd #{local_directory}/resources; git checkout -q master;"
    system "git clone -q #{remote_directory}/working #{local_directory}/working"
    system "cd #{local_directory}/working; git checkout -q master;"

    # Create the user's working directory unless it's already there.
    system "mkdir #{local_directory}/working/#{$settings.short_name}" unless File.directory?("#{local_directory}/working/#{$settings.short_name}")

    puts "Joined the '#{project_name}' project at:"
    puts
    puts "    #{local_directory}"
    puts
  end

end

Enzyme.register('join', Join) do
  puts "#{$format.bold}SYNOPSIS#{$format.normal}"
  puts '     enzyme join <project_name>'
  puts
  puts "#{$format.bold}EXAMPLES#{$format.normal}"
  puts '     enzyme join abc'
  puts
end
