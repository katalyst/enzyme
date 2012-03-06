module List extend self

  def run()
    ARGV.reject { |x| x.start_with?("-") }
  end

end