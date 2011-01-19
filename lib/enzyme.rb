module Enzyme extend self

  @@commands = {}

  def run
    # Only shift the first argument off the ARGV if help flags haven't been passed.
    command = (ARGV.delete("-h") || ARGV.delete("--help")) ? 'help' : (ARGV.shift || 'help')

    # Show info, help or run the requested command if it has been registered.
    begin
      if command.eql?('help')
        help
      else
        if @@commands.include?(command.to_s.downcase)
          @@commands[command.to_s.downcase][:class].run()
        else
          error("Unable to find command `#{command}`.")
          help
        end
      end
    rescue StandardError => e
      error(e)
    end
  end

  def info
    puts 'ENZYME'
    puts '======'
    puts ''
    puts 'Katalyst\'s project collaboration tool.'
    puts ''
    puts 'Version: '+$version
    puts ''
  end

  def help
    ARGV.reject { |x| x.start_with?("-") }
    command = ARGV.shift

    info

    if command
      if @@commands.include?(command.to_s.downcase)
        @@commands[command.to_s.downcase][:help].call
      else
        error("No help available for `#{name}`.")
      end
    else
      puts 'USAGE'
      puts '-----'
      puts ''
      puts '### Commands'
      puts ''
      puts '    enzyme config [<key> [<value> [--global]]]'
      puts '    enzyme create <project_name> [pms | koi]'
      # puts '    enzyme join <project_name>'
      puts '    enzyme sync [<project_name>]'
      puts ''
      puts '### Help'
      puts ''
      puts '    enzyme help [<command>]'
      puts '    enzyme [<command>] --help'
      puts '    enzyme [<command>] -h'
      puts ''
      puts '### Debugging'
      puts ''
      puts 'Use `--trace` at anytime to get full stacktraces.'
      puts ''
    end
  end

  def error(error)
    if $trace_errors && error.is_a?(StandardError)
      raise error
    else
      puts 'ERROR'
      puts '-----'
      puts ''
      puts '> '+error
      puts ''
    end
  end

  def register(command_class, &block)
    @@commands[command_class.to_s.downcase] = { :class => command_class, :help => block }
  end

end