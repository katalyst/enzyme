# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{enzyme}
  s.version = "1.0.0.beta03"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Haydn Ewers}]
  s.date = %q{2012-08-01}
  s.description = %q{Enzyme is a tool to make collaborating on projects easier. Developed by Katalyst Interactive.}
  s.email = %q{haydn@katalyst.com.au}
  s.executables = [%q{enzyme}]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "VERSION",
    "bin/enzyme",
    "lib/commands/config.rb",
    "lib/commands/create.rb",
    "lib/commands/join.rb",
    "lib/commands/sync.rb",
    "lib/enzyme.rb",
    "lib/errors.rb",
    "lib/hash.rb",
    "lib/setup.rb",
    "lib/string.rb"
  ]
  s.homepage = %q{http://github.com/katalyst/enzyme}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Katalyst's project collaboration tool.}
  s.test_files = [
    "test/helper.rb",
    "test/test_enzyme.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, ["= 0.9.2"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rake>, ["= 0.9.2"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, ["= 0.9.2"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

