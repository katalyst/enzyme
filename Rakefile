require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "enzyme"
  gem.homepage = "http://github.com/katalyst/enzyme"
  gem.license = "MIT"
  gem.summary = %Q{Katalyst's project collaboration tool.}
  gem.description = %Q{Enzyme is a tool to make collaborating on projects easier. Developed by Katalyst Interactive.}
  gem.email = "haydn@katalyst.com.au"
  gem.authors = ["Haydn Ewers"]
  gem.files = [
    "bin/enzyme",
    "enzyme-manual.pdf",
    "lib/commands/config.rb",
    "lib/commands/create.rb",
    "lib/commands/join.rb",
    "lib/commands/man.rb",
    "lib/commands/sync.rb",
    "lib/enzyme.rb",
    "lib/errors.rb",
    "lib/hash.rb",
    "lib/setup.rb",
    "lib/string.rb",
    "VERSION"
  ]
  gem.executables = ["enzyme"]
  gem.require_paths = ["lib"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  # gem.add_runtime_dependency 'octopi', '> 0.4.0'
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "enzyme #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
