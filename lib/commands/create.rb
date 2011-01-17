require 'enzyme'
require 'commands/config'
require 'commands/help'

module Create extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    project_name = ARGV.shift
    project_type = ARGV.shift

    if project_name
      case project_type and project_type.to_sym
      when :pms
        pms(project_name)
      else
        base(project_name)
      end
    else
      Enzyme.error("A project name must be given. For example: `enzyme create project_name`")
    end
  end

  def base(project_name)
    system "mkdir #{$settings.projects_directory}/#{project_name}"
    system "mkdir #{$settings.projects_directory}/#{project_name}/resources"
    system "mkdir #{$settings.projects_directory}/#{project_name}/resources/client"
    system "touch #{$settings.projects_directory}/#{project_name}/.enzyme.yml"

    Dir.chdir("#{$settings.projects_directory}/#{project_name}")

    Config.set('project_name', project_name)
    Config.set('project_type', nil)
  end

  def koi(project_name)
    #
  end

  def pms(project_name)
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
  puts '    enzyme create project_name [type]'
  puts ''
  puts '### EXAMPLES'
  puts ''
  puts '    enzyme create my_project pms'
  puts ''
  puts '    enzyme create another_project koi'
  puts ''
end