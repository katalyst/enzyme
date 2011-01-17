module Tasks extend self

  def run(user=nil)
    ARGV.reject { |x| x.start_with?("-") }
  end

end