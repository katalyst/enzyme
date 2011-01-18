require 'enzyme'
require 'commands/config'

module Create extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    project_name = ARGV.shift
    project_type = ARGV.shift

    if project_name
      if project_type
        case project_type.to_sym
        when :pms
          pms(project_name)
        when :koi
          koi(project_name)
        else
          Enzyme.error("Unknown project type `#{project_type}`.")
        end
      else
        base(project_name)
      end
    else
      Enzyme.error("A project name must be given. For example: `enzyme create project_name`")
    end
  end

  def base(project_name)
    unless $settings.projects_directory
      Enzyme.error("The `sync.projects_directory` setting is not set. Set it using `enzyme config projects_directory \"/Users/me/Projects\"`.")
      return
    end

    system "mkdir #{$settings.projects_directory}/#{project_name}"
    system "mkdir #{$settings.projects_directory}/#{project_name}/resources"
    system "mkdir #{$settings.projects_directory}/#{project_name}/resources/client"
    system "touch #{$settings.projects_directory}/#{project_name}/.enzyme.yml"

    Dir.chdir("#{$settings.projects_directory}/#{project_name}")

    Config.set('project_name', project_name)
    Config.set('project_type', nil)
  end

  def koi(project_name)
    Enzyme.error("Koi projects are not avaliable in this version of Enzyme (#{$version}).")
  end

  def pms(project_name)
    unless $settings.projects_directory
      Enzyme.error("The `sync.projects_directory` setting is not set. Set it using `enzyme config projects_directory \"/Users/me/Projects\"`.")
      return
    end

    unless $settings.github.user
      Enzyme.error("The `sync.github.user` setting is not set. Set it using `enzyme config github.user \"me\"`.")
      return
    end

    unless $settings.github.token
      Enzyme.error("The `sync.github.token` setting is not set. Set it using `enzyme config github.token \"0123456789abcdef0123456789abcdef\"`.")
      return
    end

    base(project_name)

    Config.set('project_type', 'pms')

    system "curl -o '/tmp/#{project_name}.zip' -F 'login=#{$settings.github.user}' -F 'token=#{$settings.github.token}' -L 'https://github.com/katalyst/pms/zipball/v0.4.2alpha03'"
    system "unzip '/tmp/#{project_name}.zip' -d '/tmp/#{project_name}.temp'"
    system "rm '/tmp/#{project_name}.zip'"

    extracted_dir = Dir.entries("/tmp/#{project_name}.temp")[2]

    system "mv /tmp/#{project_name}.temp/#{extracted_dir}/* #{$settings.projects_directory}/#{project_name}/"
    system "rm -r '/tmp/#{project_name}.temp'"
  end

end

Enzyme.register(Create) do
  puts 'CREATE COMMAND'
  puts '--------------'
  puts ''
  puts '### SYNOPSIS'
  puts ''
  puts '    enzyme create project_name [pms]'
  puts ''
  puts '### EXAMPLES'
  puts ''
  puts '    enzyme create my_project pms'
  # puts ''
  # puts '    enzyme create another_project koi'
  puts ''
end