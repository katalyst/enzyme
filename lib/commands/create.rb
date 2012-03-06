require 'enzyme'
require 'commands/config'
require 'commands/sync'

module Create extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    @@project_name = ARGV.shift
    @@project_template = ARGV.shift

    Config.prompt_for('projects_directory', true)

    if @@project_name
      if @@project_template
        case @@project_template.to_sym
        when :koi
          @@project_template = 'katalyst/koi_cms'
        end
        specific
      else
        base
      end

      # Try to init the sync.
      Sync.init(@@project_name) rescue raise "Unabled to init sync. Run 'enzyme sync --init' to initialise sync."

      puts "#{$format.bold}Project created at '#{Config.get('projects_directory')}/#{@@project_name}'.#{$format.normal}"
      puts
    else
      raise "A project name must be given. For example: 'enzyme create abc-v2'"
    end
  end

  def base
    # Tell the user what is happening.
    puts "#{$format.bold}Creating '#{Config.get('projects_directory')}/#{@@project_name}'...#{$format.normal}"
    puts
    sleep 2

    # If the project already exists, raise don't do anything.
    raise "A project already exists at '#{Config.get('projects_directory')}/#{@@project_name}'." if File.directory?("#{Config.get('projects_directory')}/#{@@project_name}")

    # Create the project's directory.
    system "mkdir #{Config.get('projects_directory')}/#{@@project_name}"

    # Change into the directory.
    system "cd #{Config.get('projects_directory')}/#{@@project_name}"
    Dir.chdir("#{Config.get('projects_directory')}/#{@@project_name}")

    # Set a default settings (creates .enzyme.yml).
    Config.set('project_name', @@project_name)
    Config.set('project_template', nil)

    # Initialise Git & Git-Flow.
    puts "#{$format.bold}Initialising Git & Git-Flow...#{$format.normal}"
    puts
    sleep 2
    system "git flow init"
    puts

    # Create and commit the VERSION file.
    puts "#{$format.bold}Creating & committing the VERSION file...#{$format.normal}"
    puts
    sleep 2
    system "echo '0.0.0' > VERSION"
    system "git add VERSION"
    system "git commit -v -m 'Added the VERSION file.'"
    puts

    # Add the enzyme config file to gitignore.
    puts "#{$format.bold}Adding '.enzyme.yml' to gitignore...#{$format.normal}"
    puts
    sleep 2
    system "echo '.enzyme.yml' >> .gitignore"
    system "git add .gitignore"
    system "git commit -m 'Added .enzyme.yml to gitignore.'"
    puts
  end

  def specific
    Config.prompt_for('github.user', true)
    Config.prompt_for('github.token', true)

    base

    Config.set('project.template', @@project_template)

    system "cd #{Config.get('projects_directory')}/#{@@project_name}"
    Dir.chdir("#{Config.get('projects_directory')}/#{@@project_name}")

    puts "Downloading project template from 'https://github.com/#{@@project_template}/zipball/master'..."
    puts
    system "curl -o '/tmp/#{@@project_name}.zip' -F 'login=#{Config.get('github.user')}' -F 'token=#{Config.get('github.token')}' -L 'https://github.com/#{@@project_template}/zipball/master'"
    puts

    puts 'Extracting...'
    puts

    system "unzip -q '/tmp/#{@@project_name}.zip' -d '/tmp/#{@@project_name}.temp'"
    system "rm '/tmp/#{@@project_name}.zip'"
    extracted_dir = Dir.entries("/tmp/#{@@project_name}.temp")[2]
    puts

    puts "Copying to '#{Config.get('projects_directory')}/#{@@project_name}/'..."
    puts

    system "mv -nf /tmp/#{@@project_name}.temp/#{extracted_dir}/* /tmp/#{@@project_name}.temp/#{extracted_dir}/.* #{Config.get('projects_directory')}/#{@@project_name}"
    system "rm -r '/tmp/#{@@project_name}.temp'"
    puts

    puts "Committing project base..."
    puts

    system("git add .")
    system("git commit -va -m 'Imported project base from https://github.com/#{@@project_template}/zipball/master.'")
    puts
  end

end

Enzyme.register('create', Create) do
  puts "#{$format.bold}SYNOPSIS#{$format.normal}"
  puts '     enzyme create <project_name> [koi|<project_template>]'
  puts
  puts "#{$format.bold}EXAMPLES#{$format.normal}"
  puts '     enzyme create prj koi # Creates a Koi project called \'prj\'.'
  puts '     enzyme create prj katalyst/koi_cms # Creates a Koi project called \'prj\'.'
  puts '     enzyme create prj unicorngames/horseshoe'
  puts
end