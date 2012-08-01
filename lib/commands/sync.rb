require 'enzyme'

module Sync extend self

  def run
    skip_resources = !!ARGV.delete("--skip-resources")
    skip_production = !!ARGV.delete("--skip-production")
    ARGV.each { |x| raise UnknownOption.new(x) if x.start_with?("-") }
    project_name = ARGV.shift || $settings.project_name
    ARGV.each { |x| raise UnknownArgument.new(x) }

    raise ArgumentOrSettingMissing.new("project_name", "project_name") unless project_name
    raise SettingMissing.new("projects_directory") unless $settings.projects_directory
    raise SettingMissing.new("short_name") unless $settings.short_name

    directory = "#{$settings.projects_directory}/#{project_name}"

    raise CannotFindProject.new(directory) unless File.directory?(directory)

    puts "Syncing project '#{project_name}' at '#{directory}'..."

    # BASE

    system "cd #{directory}"
    Dir.chdir("#{directory}")
    print "."

    system "git add .enzyme.yml &> /dev/null"
    print "."
    system "git commit -q -m 'Enzyme sync.' &> /dev/null"
    print "."
    system "git pull -q &> /dev/null"
    print "."
    system "git push -q &> /dev/null"
    puts

    # RESOURCES

    unless skip_resources
      # TODO: Check if the directory exists.

      puts "Syncing resources directory..."

      system "cd #{directory}/resources"
      Dir.chdir("#{directory}/resources")
      print "."

      system "git checkout -q . &> /dev/null"
      print "."
      system "git add . &> /dev/null"
      print "."
      system "git commit -q -m 'Enzyme sync.' &> /dev/null"
      print "."
      system "git pull -q &> /dev/null"
      print "."
      system "git push -q &> /dev/null"
      puts
    end

    # PRODUCTION

    unless skip_production
      # TODO: Check if the directory exists.

      puts "Syncing production directory..."

      system "cd #{directory}/production"
      Dir.chdir("#{directory}/production")
      print "."

      system "git add #{$settings.short_name} &> /dev/null"
      print "."
      system "git add -u &> /dev/null"
      print "."
      system "git commit -q -a -m 'Enzyme sync.' &> /dev/null"
      print "."
      system "git clean -fd &> /dev/null"
      print "."
      system "git pull -q &> /dev/null"
      print "."
      system "git push -q &> /dev/null"
      puts
    end

    puts "Done."
  end

end

Enzyme.register('sync', Sync) do
  puts "#{$format.bold}SYNOPSIS#{$format.normal}"
  puts "       enzyme sync [<project_name>] [--skip-resources] [--skip-production]"
  puts
  puts "#{$format.bold}DESCRIPTION#{$format.normal}"
  puts "       Sync either the current project or a specified project with the sync server."
  puts
  puts "       Any changes in the production directory outside of the current user's production directory"
  puts "       will be discarded."
  puts
  puts "       Only additions to the the resources directory will be kept. Any modifications to exsiting"
  puts "       references will be lost."
  puts
  puts "#{$format.bold}EXAMPLES#{$format.normal}"
  puts "        1. Syncing a specific project:"
  puts
  puts "               $ enzyme sync abc"
  puts "               Syncing project 'abc' at '/Users/jane/Projects/abc'..."
  puts "               ...."
  puts "               Syncing resources directory..."
  puts "               ....."
  puts "               Syncing production directory..."
  puts "               ......"
  puts "               Done."
  puts
  puts "        2. Syncing the current project:"
  puts
  puts "               $ cd /Users/jane/Projects/abc"
  puts "               $ enzyme sync"
  puts "               Syncing project 'abc' at '/Users/jane/Projects/abc'..."
  puts "               ...."
  puts "               Syncing resources directory..."
  puts "               ....."
  puts "               Syncing production directory..."
  puts "               ......"
  puts "               Done."
end
