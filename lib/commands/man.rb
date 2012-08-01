require 'enzyme'
require 'commands/config'

module Man extend self

  def run()
    ARGV.each { |x| raise UnknownOption.new(x) if x.start_with?("-") }
    ARGV.each { |x| raise UnknownArgument.new(x) }

    path = File.join(File.dirname(__FILE__), '..', '..', 'enzyme-manual.pdf')

    system "open #{path}"
  end

end

Enzyme.register('man', Man) do
  puts "#{$format.bold}SYNOPSIS#{$format.normal}"
  puts "       enzyme man"
  puts
  puts "#{$format.bold}DESCRIPTION#{$format.normal}"
  puts "       Opens the manual PDF."
end
