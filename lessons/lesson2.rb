#!/usr/bin/env ruby

# LOOPS: for, while, and until

ary = [1, 2, 3, 4, 5]

puts "for loop example"
for e in ary do 
  puts e
end


# while loop
puts "While loop example"
i = 4
while i >= 0 do
  puts "#{i}: #{ary[i]}"
  i = i - 1
end

# until loop
puts "until loop example"
i = 4
until i < 0 do
  puts "#{i}: #{ary[i]}"
  i -= 1
end

# postfix form for loops:
puts "postfix example"
a = 10
puts a -= 2 while a > 0


# OBJECT-ORIENTED PROGRAMMING

# Functions (or methods)
puts "Functions examples"

def greet(name, hour=12)
  # function body
  if hour < 12 then
    msg = 'morning'
  elsif hour < 15 then
    msg = 'afternoon'
  elsif hour < 18 then
    msg = 'evening'
  else
    msg = 'night'
  end
  puts "Good #{msg}, #{name}!"
end

greet("Paolo", 17)
greet "Paolo"


# Objects (or Classes) and Instances

a = [1,2,3]

for i in 0..(a.count) do 
  puts "a[#{i}] = #{a[i]}"
end

# Class definition
class Chalk
  attr_accessor :blackboard #also attr_reader and attr_writer
  
  def initialize(length=50)
    # attributes are variables starting with @
    @length = length
    @blackboard = []
  end
  
  def length; @length; end # GETTER
  def length=(new_value)   # SETTER method for @length
    @length = new_value
  end

  # returns a string and decrements @lenght accordingly
  def writings(str)
    return "*" if @length < 10
    @length -= str.length
    return str
  end
  
  # writes to the console 
  def write(str)
    puts self.writings(str)
  end # write
  
end # class Chalk 

c = Chalk.new(25)

for i in 0..50 do
  c.write "Hello!"
  puts "chalk length is #{c.length}"
end

c.length = 30 # as writing c.length=(30)
























