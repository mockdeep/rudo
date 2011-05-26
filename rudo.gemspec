Gem::Specification.new do |s|
  s.name = %q{rudo}
  s.version = "0.0.8"
  s.date = %q{2011-05-15}
  s.authors = ["Robert Fletcher"]
  s.email = %q{lobatifricha@gmail.com}
  s.summary = %q{A simple, semi-pretty command line based todo list manager}
  s.homepage = %q{https://github.com/mockdeep/rudo}
  s.description = %q{Tasks are saved in ~/rudo.yml}
  s.files = %w[
    lib/rudo.rb
    bin/rudo
    bin/rad
    bin/dun
    bin/walk
  ]
  s.executables = ["rudo", "rad", "dun", "walk"]
  s.add_dependency('colored', '>= 1.2')
  s.add_dependency('trollop', '>= 1.16.2')
end
