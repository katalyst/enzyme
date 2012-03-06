require 'enzyme'
require 'commands/config'
require 'commands/sync'

module Join extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
    @@project_name = ARGV.shift

    if @@project_name
      raise "The `projects_directory` setting is not set. Set it using `enzyme config projects_directory \"/Users/me/Projects\" --global`." unless $settings.projects_directory
      raise "The `sync.shared_directory` setting is not set. Set it using `enzyme config sync.shared_directory \"shared\" --global`." unless $settings.sync.shared_directory
      raise "The `user` setting is not set. Set it using `enzyme config user \"me\" --global`." unless $settings.user

      puts "Joining the '#{@@project_name}' project at '#{$settings.projects_directory}/#{@@project_name}'..."
      puts

      # system "git clone #{$settings.projects_directory}/#{@@project_name}"

      system "mkdir #{$settings.projects_directory}/#{@@project_name}"

      Dir.chdir("#{$settings.projects_directory}/#{@@project_name}")

      Sync.init(@@project_name)

      Config.set('project_name', @@project_name)
      Config.set('project_type', nil)

      puts "Complete."
      puts
    else
      raise "A project name must be given. For example: `enzyme join project_name`"
    end
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