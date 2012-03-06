class Hash

  # From: http://www.ruby-forum.com/topic/142809
  # Author: Stefan Rusterholz
  def deep_merge(second)
     merger = proc { |key,v1,v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
     self.merge(second, &merger)
  end

  # Make hashes act like ECMAScript objects.
  def method_missing(sym, *args)
    if sym.to_s =~ /(.+)=$/
      self[$1] = args.first
    else
      self[sym] || self[sym.to_s]
    end
  end

end