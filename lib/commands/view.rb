module View extend self

  def run(what=nil)
    ARGV.reject { |x| x.start_with?("-") }
  end

end