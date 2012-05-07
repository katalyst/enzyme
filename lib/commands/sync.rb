require 'enzyme'

module Sync extend self

  def run
    skip_resources = !!ARGV.delete("--skip-resources")
    skip_working = !!ARGV.delete("--skip-working")
    ARGV.each { |x| raise UnknownOption.new(x) if x.start_with?("-") }
    project_name = ARGV.shift || $settings.project_name
    ARGV.each { |x| raise UnknownArgument.new(x) }

    raise ArgumentOrSettingMissing.new("project_name", "project_name") unless project_name
    raise SettingMissing.new("projects_directory") unless $settings.projects_directory

    directory = "#{$settings.projects_directory}/#{project_name}"

    raise CannotFindProject.new(directory) unless File.directory?(directory)

    # BASE

    system "cd #{directory}"
    Dir.chdir("#{directory}")

    system "git add .enzyme.yml > /dev/null"
    system "git commit -m 'Enzyme sync.'"
    system "git pull > /dev/null"
    system "git push > /dev/null"

    # SHARED

    unless skip_resources
      system "cd #{directory}/resources"
      Dir.chdir("#{directory}/resources")

      system "git checkout -q . > /dev/null"
      system "git add . > /dev/null"
      system "git commit -m 'Enzyme sync.'"
      system "git pull > /dev/null"
      system "git push > /dev/null"
    end

    # WORKING

    system "cd #{directory}/working"
    Dir.chdir("#{directory}/working")

    system "git add #{$settings.short_name} > /dev/null"
    system "git add -u > /dev/null"
    system "git commit -a -m 'Enzyme sync.'"
    system "git clean -fd > /dev/null"
    system "git pull > /dev/null"
    system "git push > /dev/null"
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
