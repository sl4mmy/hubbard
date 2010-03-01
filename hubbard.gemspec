# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hubbard}
  s.version = "0.0.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Foemmel"]
  s.date = %q{2010-03-01}
  s.default_executable = %q{hubbard}
  s.description = %q{Hubbard is a command line tool for managing git repositories.}
  s.email = %q{git@foemmel.com}
  s.executables = ["hubbard"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "bin/hubbard",
     "commands/add-key.rb",
     "commands/add-permission.rb",
     "commands/create-project.rb",
     "commands/create-repository.rb",
     "commands/delete-project.rb",
     "commands/fork-repository.rb",
     "commands/git-receive-pack.rb",
     "commands/git-upload-pack.rb",
     "commands/list-forks.rb",
     "commands/list-keys.rb",
     "commands/list-permissions.rb",
     "commands/list-projects.rb",
     "commands/list-repositories.rb",
     "commands/list-users.rb",
     "commands/move-repository.rb",
     "commands/remove-key.rb",
     "commands/remove-permission.rb",
     "commands/rename-project.rb",
     "commands/set-description.rb",
     "commands/set-visibility.rb",
     "commands/whoami.rb",
     "hubbard.gemspec",
     "lib/hubbard.rb",
     "spec/gitssh",
     "spec/hubbard_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/yaml_spec.rb"
  ]
  s.homepage = %q{http://github.com/mfoemmel/hubbard}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Hubbard is a command line tool for managing git repositories.}
  s.test_files = [
    "spec/yaml_spec.rb",
     "spec/hubbard_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

