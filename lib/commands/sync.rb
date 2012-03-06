require 'enzyme'

module Sync extend self

  def preflight
    Config.prompt_for('projects_directory', true)
    Config.prompt_for('user', true)
    Config.prompt_for('sync.projects_directory', true)
  end

  def run
    discard_changes = ARGV.delete("--discard-changes")
    init_action = ARGV.delete("--init")
    ARGV.reject { |x| x.start_with?("-") }
    project_name = ARGV.shift || Config.get('project_name')

    raise "No project name specified. Ensure you're in the project's directory or set it specifically. Run `enzyme help sync` for help." unless project_name
    raise "The #{project_name} project could not be found." unless File.exist?("#{Config.get('sync.projects_directory')}/#{project_name}")

    if init_action
      init(project_name)
    else
      preflight

      system "cd #{Config.get('sync.projects_directory')}/#{project_name}/_resources"
      Dir.chdir("#{Config.get('sync.projects_directory')}/#{project_name}/_resources")

      unless discard_changes
        system "git add shared"
        system "git add #{Config.get('user')}"
        system "git commit -m 'Automated commit via Enzyme sync.'"
      end

      system "git checkout ."
      system "git clean -fd"
      system "git pull"
      system "git push"
    end
  end

  def init(project_name)
    preflight

    # Tell the user what is happening.
    puts "#{$format.bold}Initialising sync directory...#{$format.normal}"
    puts
    sleep 2

    # Check the sync project's directory exists & the project doesn't already exist in there.
    raise "Unabled to find directory #{Config.get('sync.projects_directory')}. If it's on an external volume, ensure it has been mounted." unless File.directory?(Config.get('sync.projects_directory'))
    raise "A project already exists at '#{Config.get('sync.projects_directory')}/#{project_name}'." if File.directory?("#{Config.get('sync.projects_directory')}/#{project_name}")

    puts "#{$format.bold}Cloning the local project to make the remote version...#{$format.normal}"
    puts
    sleep 2

    # FIXME: This ends up with a remote that's kind of weird...
    # Clone the local project into the remote project's directory.
    system "git clone #{Config.get('projects_directory')}/#{project_name} #{Config.get('sync.projects_directory')}/#{project_name}"
    puts

    puts "#{$format.bold}Creating the remote resources directory...#{$format.normal}"
    puts
    sleep 2

    # Create the remote resources directory.
    system "mkdir #{Config.get('sync.projects_directory')}/#{project_name}/_resources"
    system "mkdir #{Config.get('sync.projects_directory')}/#{project_name}/_resources/shared"
    system "mkdir #{Config.get('sync.projects_directory')}/#{project_name}/_resources/#{Config.get('user')}"
    create_readme("#{Config.get('sync.projects_directory')}/#{project_name}/_resources/README")

    # Change into the remote resources directory.
    system "cd #{Config.get('sync.projects_directory')}/#{project_name}/_resources"
    Dir.chdir("#{Config.get('sync.projects_directory')}/#{project_name}/_resources")

    # Do the inital commit.
    system "git init"
    system "git add ."
    system "git commit -m 'Initialised via Enzyme sync.'"
    puts

    puts "#{$format.bold}Cloning the remote resources directory to the local project...#{$format.normal}"
    puts
    sleep 2

    # Clone the remote resources directory into the local project.
    system "git clone #{Config.get('sync.projects_directory')}/#{project_name}/_resources #{Config.get('projects_directory')}/#{project_name}/_resources"

    # Make the empty directories that wouldn't have been cloned.
    system "mkdir #{Config.get('projects_directory')}/#{project_name}/_resources/shared"
    system "mkdir #{Config.get('projects_directory')}/#{project_name}/_resources/#{Config.get('user')}"
    puts

    puts "#{$format.bold}Checking '_resources' is in gitignore...#{$format.normal}"
    puts
    sleep 2

    # Change into the local project's directory.
    system "cd #{Config.get('projects_directory')}/#{project_name}"
    Dir.chdir("#{Config.get('projects_directory')}/#{project_name}")

    # If the .gitignore file doesn't contain the resources folder, add it.
    if `cat .gitignore | grep '^_resources$'`.strip.empty?
      system "echo '_resources' >> .gitignore"
      system "git add .gitignore"
      system "git commit -m 'Added _resources to gitignore.'"
      puts
    end
  end

private

  def create_readme(location)
    text = "http://github.com/katalyst/kat-ezm\n\nRules\n-----\n\n- Never modify other people's files. Any changes you make to someone else's files will be lost when you sync.\n- Avoid modifying shared files, instead make a copy into your own folder.\n- Prefix files/folders in the shared folder with the date (YYYY-MM-DD).\n"
    File.open(location, "w") { |f| f.write(text) }
  end

end

Enzyme.register('sync', Sync) do
  puts "#{$format.bold}SYNOPSIS#{$format.normal}"
  puts '     enzyme sync [<project_name>] [--discard-changes] [--init]'
  puts
  puts "#{$format.bold}DESCRIPTION#{$format.normal}"
  puts '     Options:'
  puts
  puts "     #{$format.bold}<project_name>#{$format.normal}"
  puts '             The name of the project to sync. If the working directory is the root of a project this option does not need to be passed.'
  puts
  puts "#{$format.bold}EXAMPLES#{$format.normal}"
  puts '     You can run sync like this:'
  puts
  puts '     enzyme sync another_project'
  puts '             If you specify a project you can run sync from anywhere.'
  puts
  puts '     cd ~/Projects/my_project'
  puts '     enzyme sync'
  puts '             When the working directory is the root of a project you can run sync without any arguments.'
  puts
end