Gem::Specification.new do |s|
  s.name = %q{rudo}
  s.version = "0.0.3"
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
end
