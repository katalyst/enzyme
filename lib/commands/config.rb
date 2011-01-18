require 'yaml'
require 'hash'
require 'enzyme'

module Config extend self

  GLOBAL_FILENAME = "#{ENV['HOME']}/.enzyme.yml"
  PROJECT_FILENAME = "./.enzyme.yml"

  def run()
    global = ARGV.delete('--global')
    ARGV.reject { |x| x.start_with?("-") }
    key = ARGV.shift
    value = ARGV.shift

    unless value === nil
      set(key, value, global)
    else
      val = get(key)
      if val.is_a?(Array) || val.is_a?(Hash) || val.is_a?(Settings)
        puts val.to_hash.to_yaml
      else
        puts val.to_s
      end
    end
  end

  def get(key)
    s = $settings
    key.split('.').each { |o| s = s[o] } if key
    s
  end

  def set(key, value, global=false)
    filename = global ? GLOBAL_FILENAME : PROJECT_FILENAME
    settings = YAML.load_file(filename) || {}

    # FIXME: This could be simplified... heaps.
    newSettings = {}
    n = newSettings
    keys = key.to_s.split(".")
    keys.each do |k|
      k = k.to_i if k == k.to_i.to_s
      n[k] = (k == keys.last) ? value : {}
      n = n[k]
    end

    settings = settings.deep_merge(newSettings)

    File.open(filename, "w") { |f| f.write(settings.to_yaml) }
  end

end

Enzyme.register(Config) do
  puts 'CONFIG COMMAND'
  puts '--------------'
  puts ''
  puts '### SYNOPSIS'
  puts ''
  puts '    enzyme config [key [value [--global]]]'
  puts ''
  puts '### EXAMPLES'
  puts ''
  puts '    enzyme config user dave --global'
  puts ''
  puts '    enzyme config user'
  puts '    > dave'
  puts ''
  puts '    enzyme config project_name my_project'
  puts ''
  puts '    enzyme config project_name'
  puts '    > my_project'
  puts ''
end