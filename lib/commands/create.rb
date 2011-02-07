require 'enzyme'
require 'commands/config'

module Create extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    @@project_name = ARGV.shift
    @@project_type = ARGV.shift

    if @@project_name
      if @@project_type
        case @@project_type.to_sym
        when :pms
          pms
        when :koi
          koi
        else
          raise "Unknown project type `#{project_type}`."
        end
      else
        base
      end
      puts
      puts "Complete."
      puts
    else
      raise "A project name must be given. For example: `enzyme create project_name`"
    end
  end

  def base
    raise "The `projects_directory` setting is not set. Set it using `enzyme config projects_directory \"/Users/me/Projects\" --global`." unless $settings.projects_directory
    raise "The `sync.shared_directory` setting is not set. Set it using `enzyme config sync.shared_directory \"shared\" --global`." unless $settings.sync.shared_directory
    raise "The `user` setting is not set. Set it using `enzyme config user \"me\" --global`." unless $settings.user

    @@project_name = @@project_name+'_'+Time.now.strftime('%y%m') unless @@project_name =~ /^.+_\d{4}$/

    puts
    puts "Creating the '#{@@project_name}' project at '#{$settings.projects_directory}/#{@@project_name}'..."
    puts

    system "mkdir #{$settings.projects_directory}/#{@@project_name}"
    # TODO: Move the resources directory and it's content to the sync command. Create shouldn't be responsible for it.
    system "mkdir #{$settings.projects_directory}/#{@@project_name}/resources"
    system "mkdir #{$settings.projects_directory}/#{@@project_name}/resources/#{$settings.sync.shared_directory}"
    system "mkdir #{$settings.projects_directory}/#{@@project_name}/resources/#{$settings.user}"
    system "touch #{$settings.projects_directory}/#{@@project_name}/.enzyme.yml"

    Dir.chdir("#{$settings.projects_directory}/#{@@project_name}")

    Config.set('project_name', @@project_name)
    Config.set('project_type', nil)
  end

  def koi
    raise "The `projects_directory` setting is not set. Set it using `enzyme config projects_directory \"/Users/me/Projects\" --global`." unless $settings.projects_directory
    raise "The `github.user` setting is not set. Set it using `enzyme config github.user \"me\" --global`." unless $settings.github.user
    raise "The `github.token` setting is not set. Set it using `enzyme config github.token \"0123456789abcdef0123456789abcdef\" --global`." unless $settings.github.token

    base

    Config.set('project_type', 'koi')

    puts
    puts "Downloading the latest version of Koi from 'https://github.com/katalyst/koi_cms/zipball/master'..."
    puts

    system "curl -o '/tmp/#{@@project_name}.zip' -F 'login=#{$settings.github.user}' -F 'token=#{$settings.github.token}' -L 'https://github.com/katalyst/koi_cms/zipball/master'"

    puts
    puts 'Extracting...'
    puts

    system "unzip '/tmp/#{@@project_name}.zip' -d '/tmp/#{@@project_name}.temp'"
    system "rm '/tmp/#{@@project_name}.zip'"

    extracted_dir = Dir.entries("/tmp/#{@@project_name}.temp")[2]

    puts
    puts "Copying to '#{$settings.projects_directory}/#{@@project_name}/'..."
    puts

    system "mv /tmp/#{@@project_name}.temp/#{extracted_dir}/* #{$settings.projects_directory}/#{@@project_name}"
    system "rm -r '/tmp/#{@@project_name}.temp'"
  end

  def pms
    raise "The `projects_directory` setting is not set. Set it using `enzyme config projects_directory \"/Users/me/Projects\" --global`." unless $settings.projects_directory
    raise "The `github.user` setting is not set. Set it using `enzyme config github.user \"me\" --global`." unless $settings.github.user
    raise "The `github.token` setting is not set. Set it using `enzyme config github.token \"0123456789abcdef0123456789abcdef\" --global`." unless $settings.github.token

    base

    Config.set('project_type', 'pms')

    puts
    puts "Downloading v0.4.2alpha03 of the PMS from 'https://github.com/katalyst/pms/zipball/v0.4.2alpha03'..."
    puts

    system "curl -o '/tmp/#{@@project_name}.zip' -F 'login=#{$settings.github.user}' -F 'token=#{$settings.github.token}' -L 'https://github.com/katalyst/pms/zipball/v0.4.2alpha03'"

    puts
    puts 'Extracting...'
    puts

    system "unzip '/tmp/#{@@project_name}.zip' -d '/tmp/#{@@project_name}.temp'"
    system "rm '/tmp/#{@@project_name}.zip'"

    extracted_dir = Dir.entries("/tmp/#{@@project_name}.temp")[2]

    puts
    puts "Copying to '#{$settings.projects_directory}/#{@@project_name}/'..."
    puts

    system "mv /tmp/#{@@project_name}.temp/#{extracted_dir}/* #{$settings.projects_directory}/#{@@project_name}"
    system "rm -r '/tmp/#{@@project_name}.temp'"
  end

end

Enzyme.register(Create) do
  puts 'CREATE COMMAND'
  puts '--------------'
  puts ''
  puts '### SYNOPSIS'
  puts ''
  puts '    enzyme create <project_name> [pms | koi]'
  puts ''
  puts '### EXAMPLES'
  puts ''
  puts '    enzyme create my_project pms'
  puts ''
  puts '    enzyme create another_project koi'
  puts ''
end