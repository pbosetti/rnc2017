#!/usr/bin/env ruby

# Class definition
class Chalk
  attr_accessor :blackboard, :length
  attr_reader :color
  
  def initialize(length=50, color='white')
    raise ArgumentError, "length: got #{length.class}, expecting Fixnum" unless length.kind_of? Fixnum
    raise ArgumentError, "color: got #{color.class}, expecting String" unless color.kind_of? String
    @length = length
    @color = color
    @blackboard = [] # Empty Array instance
  end
  
  def inspect # MUST return a String
    return "Current chalk is #{@color} of length #{@length}\nBlackboard content: #{@blackboard.inspect}"
  end

  # returns a string and decrements @lenght accordingly
  def writings(str)
    str = str.inspect unless str.kind_of? String
    
    return "*" if @length < 10
    @length -= str.length
    @blackboard << str
    return str
  end
  
  # writes to the console 
  def write(str)
    puts self.writings(str)
  end # write
  
  def [](idx)
    return @blackboard[idx]
  end
  
  
  
end # class Chalk 



# INSTANCE CREATION METHOD:
begin
  c = Chalk.new('25') # second arg is optional, default "white"
rescue ArgumentError
  warn "Warning: error creating new Chalk, reverting to defaults"
  c = Chalk.new()
rescue => error
  warn "unexpected error: #{error}"
  exit
end



for i in 0..20 do
  c.write i           #"#{i}: Hello!"
  puts "chalk length is #{c.length}"
end
puts "Blackboard content:"
puts c[0]

puts "c description:"
p c

c.length = 30 # as writing c.length=(30)
