require 'setup'

module Enzyme extend self

  @@commands = {}

  def run
    # Only shift the first argument off the ARGV if help flags haven't been passed.
    command = (ARGV.delete("-h") || ARGV.delete("--help")) ? 'help' : (ARGV.shift || 'info')

    puts

    # Show info, help or run the requested command if it has been registered.
    begin
      if command.eql?('info')
        info
      elsif command.eql?('help')
        help
      else
        if @@commands.include?(command)
          @@commands[command][:class].run
        else
          error("Unable to find command `#{command}`.")
        end
      end
    rescue StandardError => e
      error(e)
    end
  end

  def info
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
    help
  end

  def help
    ARGV.reject { |x| x.start_with?("-") }
    command = ARGV.shift

    if command
      if @@commands.include?(command.to_s.downcase)
        @@commands[command.to_s.downcase][:help].call
      else
        error("No help available for `#{name}`.")
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
      puts '  Run `enzyme help` for help.'
      puts
    end
  end

  def register(command, command_class, &block)
    @@commands[command] = { :class => command_class, :help => block }
  end

end