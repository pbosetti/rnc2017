#!/usr/bin/env ruby


# Q1: yield()

def myfun1(arg, &b)
  b.call(arg, arg)
end

# myfun1("test") # raises an error!

def custom_p(arg)
  if block_given?
    p yield(arg)
  else
    p arg
  end
end

custom_p ["test 1", "test 2"] # => ["test 1", "test 2"]
custom_p(1.23) do |obj|
  case obj
  when String
    obj.upcase
  when Numeric
    obj.to_s.upcase
  else
    obj
  end
end

# Difference between Proc and ruby blocks
def myfun2(&b)
  p b.class
end

myfun2 {} # => Proc, so a Block IS a Proc instance

# Difference beteen #each and #map


# SELF as a pointer to the current instance

class Item
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def operate
    raise unless block_given?
    yield self
  end
end

it = Item.new("table")

it = it.operate {|o| o.name = o.name.upcase}

# SELF is a pointer (or a handle) to the current class
# to avoid the risk of having to rename a lot of class methods
class Item
  def self.describe
    puts "this is a general Item class"
  end
end











# a = "test string"
# myfun(a) {|par1| p par1} # => ["test string", "test string"]
