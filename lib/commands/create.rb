require 'enzyme'
require 'commands/config'
require 'commands/join'

module Create extend self

  def run()
    skip_join = !!ARGV.delete("--skip-join")
    ARGV.each { |x| raise UnknownOption.new(x) if x.start_with?("-") }
    project_name = ARGV.shift
    ARGV.each { |x| raise UnknownArgument.new(x) }

    raise ArgumentMissing.new("project_name") unless project_name

    create(project_name)

    Join.join(project_name) unless skip_join
  end

  def create(project_name)
    raise SyncServerRequired.new unless $system_settings.sync_server.exists
    raise SettingMissing.new("sync.projects_directory", "path/to/directory", "organisation") unless $settings.sync.projects_directory

    directory = "#{$system_settings.sync_server.path}/#{$settings.sync.projects_directory}/#{project_name}"

    # If the project already exists, raise an error.
    raise ProjectAlreadyExists.new(directory) if File.directory?(directory)

    puts "Creating remote project at '#{directory}'..."

    create_repo directory, [ "*", "!.enzyme.yml", "!.gitignore" ]
    print "."
    Config.write("#{directory}/.enzyme.yml", { "project_name" => project_name })
    print "."
    commit_repo directory
    print "."
    detach_repo directory
    print "."

    create_repo "#{directory}/resources"
    print "."
    commit_repo "#{directory}/resources"
    print "."
    detach_repo "#{directory}/resources"
    print "."

    create_repo "#{directory}/production"
    print "."
    commit_repo "#{directory}/production"
    print "."
    detach_repo "#{directory}/production"
    puts

    puts "Done."
  end

  def create_repo(path, gitignore=[])
    # Create the project's directory.
    system "mkdir -p #{path} > /dev/null"

    # Change into the directory.
    system "cd #{path} > /dev/null"
    Dir.chdir(path)

    # Gitify.
    system "git init > /dev/null"
    system "echo '#{gitignore.join("\n")}' > .gitignore"
  end

  def commit_repo(path)
    # Create the project's directory.
    system "mkdir -p #{path} > /dev/null"

    # Change into the directory.
    system "cd #{path} > /dev/null"
    Dir.chdir(path)

    # Gitify.
    system "git add . > /dev/null"
    system "git commit -m 'Initial commit.' > /dev/null"
  end

  def detach_repo(path)
    # Create the project's directory.
    system "mkdir -p #{path} > /dev/null"

    # Change into the directory.
    system "cd #{path} > /dev/null"
    Dir.chdir(path)

    # Gitify.
    system "git checkout -q --detach > /dev/null"
  end

end

Enzyme.register('create', Create) do
  puts "#{$format.bold}SYNOPSIS#{$format.normal}"
  puts "       enzyme create <project_name> [--skip-join]"
  puts
  puts "#{$format.bold}DESCRIPTION#{$format.normal}"
  puts "       Creates a project on the sync server and (if --skip-join hasn't been passed) joins the"
  puts "       project using the `enzyme join` command."
  puts
  puts "#{$format.bold}EXAMPLES#{$format.normal}"
  puts "       Creating a project called 'abc':"
  puts
  puts "               $ enzyme create abc"
  puts "               Creating remote project at '/Volumes/Shared/Projects/abc'..."
  puts "               ........"
  puts "               Done."
  puts "               Joining the 'abc' project at '/Volumes/Shared/Projects/abc'..."
  puts "               ......"
  puts "               Done."
end
