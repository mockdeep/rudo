Gem::Specification.new do |s|
  s.name = %q{rudo}
  s.version = "0.2.1"
  s.date = %q{2012-04-15}
  s.authors = ["Robert Fletcher"]
  s.email = %q{lobatifricha@gmail.com}
  s.summary = %q{A simple, semi-pretty command line based todo list manager}
  s.homepage = %q{https://github.com/mockdeep/rudo}
  s.description = %q{Tasks are saved in ~/rudo.yml}
  s.files = Dir["{lib,spec,bin}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = 'lib'

  s.executables = ["rudo", "rad", "dun", "walk"]
  s.add_dependency('colored', '>= 1.2')
  s.add_dependency('trollop', '>= 1.16.2')
end
