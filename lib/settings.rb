# From: http://mjijackson.com/2010/02/flexible-ruby-config-objects
# Author: Michael Jackson
class Settings

  def initialize(data={})
    @data = {}
    update!(data)
  end

  def update!(data)
    data.each do |key, value|
      self[key] = value
    end
  end

  def [](key)
    @data[key.to_sym] || @data[key.to_i]
  end

  def []=(key, value)
    if value.class == Hash
      @data[key.to_sym] = Settings.new(value)
    else
      @data[key.to_sym] = value
    end
  end

  def method_missing(sym, *args)
    if sym.to_s =~ /(.+)=$/
      self[$1] = args.first
    else
      self[sym]
    end
  end

end