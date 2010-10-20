task :cruise do
  system('rspec spec/*')
  puts $?
  exit(1) if $? != 0
end
