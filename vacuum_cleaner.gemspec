# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{vacuum_cleaner}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lukas Westermann"]
  s.date = %q{2010-02-24}
  s.description = %q{** Swoooosh ** - and all those leading and trailing whitespaces are gone, or ** Frooom ** - and the value
      is normalized to always be prefixed by 'http://' and much more. Works with both plain old Ruby, and Rails (ActiveModel
      and ActiveSupport).}
  s.email = %q{lukas.westermann@gmail.com}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "init.rb",
     "lib/vacuum_cleaner.rb",
     "lib/vacuum_cleaner/normalizations.rb",
     "lib/vacuum_cleaner/normalizations/method.rb",
     "lib/vacuum_cleaner/normalizations/url.rb",
     "lib/vacuum_cleaner/normalizer.rb",
     "test/test_helper.rb",
     "test/unit/vacuum_cleaner/normalizations/method_test.rb",
     "test/unit/vacuum_cleaner/normalizations/url_test.rb",
     "test/unit/vacuum_cleaner/normalizations_test.rb",
     "test/unit/vacuum_cleaner/normalizer_test.rb"
  ]
  s.homepage = %q{http://github.com/lwe/vacuum_cleaner}
  s.licenses = ["LICENSE"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Ruby (and Rails) attribute cleaning support, provides some nice default normalization strategies.}
  s.test_files = [
    "test/test_helper.rb",
     "test/unit/vacuum_cleaner/normalizations/method_test.rb",
     "test/unit/vacuum_cleaner/normalizations/url_test.rb",
     "test/unit/vacuum_cleaner/normalizations_test.rb",
     "test/unit/vacuum_cleaner/normalizer_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<shoulda>, [">= 2.10.2"])
      s.add_development_dependency(%q<rr>, [">= 0.10.5"])
    else
      s.add_dependency(%q<shoulda>, [">= 2.10.2"])
      s.add_dependency(%q<rr>, [">= 0.10.5"])
    end
  else
    s.add_dependency(%q<shoulda>, [">= 2.10.2"])
    s.add_dependency(%q<rr>, [">= 0.10.5"])
  end
end
