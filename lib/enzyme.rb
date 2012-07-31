require 'setup'

module Enzyme extend self

  @@commands = {}

  def run
    # If "-h" or "--help" was passed, delete the first one found and set the command to "help".
    # Otherwise, assume the command is the first argument passed.
    command = ARGV.delete((ARGV & [ "-h", "--help" ]).first) ? 'help' : ARGV.shift

    puts

    # Show info, help or run the requested command if it has been registered.
    begin
      if command.nil? || command.eql?('info')
        info
      elsif command.eql?('help')
        help
      else
        if @@commands.include?(command)
          @@commands[command][:class].run
        else
          raise UnknownCommand.new(command)
        end
      end
    rescue StandardError => e
      error(e)
    end
  end

  def info
    ARGV.each { |x| raise UnknownOption.new(x) if x.start_with?("-") }
    ARGV.each { |x| raise UnknownArgument.new(x) }

    puts '+-------------------------------------------------+'
    puts '| #####  ##  ##  ######  ##   ##  ##    ##  ##### |'
    puts '| ##     ### ##     ##    ## ##   ###  ###  ##    |'
    puts '| #####  ######    ##      ###    ########  ##### |'
    puts '| ##     ## ###   ##       ##     ## ## ##  ##    |'
    puts '| #####  ##  ##  ######   ##      ##    ##  ##### |'
    puts '+-------------------------------------------------+'
    puts
    puts "#{$format.bold}DESCRIPTION#{$format.normal}"
    puts '     Katalyst\'s project collaboration tool.'
    puts
    puts "#{$format.bold}VERSION#{$format.normal}"
    puts "     #{$system_settings.version}"
    puts
    puts "Run `enzyme help` for usage."
    puts
  end

  def help
    ARGV.each { |x| raise UnknownOption.new(x) if x.start_with?("-") }
    command = ARGV.shift
    ARGV.each { |x| raise UnknownArgument.new(x) }

    if command
      if @@commands.include?(command.to_s.downcase)
        @@commands[command.to_s.downcase][:help].call
      else
        error("No help available for `#{command}`.")
      end
    else
      puts "#{$format.bold}SYNOPSIS#{$format.normal}"
      puts '     enzyme <command> [<options>]'
      puts
      puts "#{$format.bold}HELP#{$format.normal}"
      puts '     enzyme help [<command>]'
      puts '     enzyme [<command>] --help'
      puts '     enzyme [<command>] -h'
      puts
      puts "#{$format.bold}COMMANDS#{$format.normal}"

      ([ "info" ]+@@commands.keys).sort.each { |command| puts "     #{command}" }

      puts
      puts "#{$format.bold}DEBUGGING#{$format.normal}"
      puts '     Use `--trace` at anytime to get full stacktraces.'
      puts '     Use `--skip-sync-server` to prevent the sync server from mounting automatically.'
      puts
    end
  end

  def error(error)
    if $system_settings.trace_errors
      raise error
    else
      puts "#{$format.bold}ERROR: #{error}#{$format.normal}"
      puts
      puts '  Run `enzyme help` for help or use the `--trace` option to get a full stacktrace.'
      puts
    end
  end

  def register(command, command_class, &block)
    @@commands[command] = { :class => command_class, :help => block }
  end

end
