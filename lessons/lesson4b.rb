#!/usr/bin/env ruby
#Command arguments get into the ARGV array

file_name = ARGV[0]
raise RuntimeError, "I need a file name as argument" unless ARGV[0]

# WRITING
File.open(file_name, "w") do |file|

  10.times do |i|
    str = "Line number #{i}"
    file.puts str
  end

end

# READING
puts "using File#readlines"
File.open(file_name, "r") do |file|
  file.readlines.each_with_index do |line, i|
    print "#{i}: #{line}"
  end
end

puts "Using File::readlines"
lines = File.readlines(file_name)
lines.each_with_index do |line, i|
  print "#{i}: #{line}"
end

puts "using File::foreach"
i = 0
File.foreach(file_name) do |line|
  print "#{i}: #{line}"
  i += 1
end


# Yield

def operate_twice(value)
  raise "Need a block!" unless block_given?
  yield value
  yield value
end

# this printw twice the line "test"
puts operate_twice("test") {|v| puts v}

a = 0
puts operate_twice(10) {|v| a += v}
# now a == 20
