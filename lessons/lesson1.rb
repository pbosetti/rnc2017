#!/usr/bin/env ruby

# The very first line is called "shebang line"
# it is mandatory!
# This file shall be made executable by running 
# chmod u+x filename.rb ,in the terminal.

# This is a comment
# NOTE 1. Ruby is a case-sensitive language

puts("Hello, World!")

# print() function is like puts() but without trailing newline
print("Hello again\n")

# Special characters: newline and tab
# tab with is typically 8 spaces on terminal
puts("A tab follows:\tthen a newline\n\t\tand a new tab")

# VARIABLES
my_var1 = 2    # integer type
my_var2 = 2.0  # floating point type (real)
my_var3 = "two"

# puts with multiple arguments
puts(my_var1, my_var2, my_var3)

# String INTERPOLATION
puts("my_var1 has a value of #{my_var1}.")
# string interpolation works on EXPRESSIONS:
puts("my_var1 + my_var2 = #{my_var1 + my_var2}.")

# Uncomment this to see an error message:
# puts my_var4

# Strings defined with single quotes DO NOT INTERPOLATE!
puts 'Not interpolated\nstring: #{my_var1}.'
# Use escape (basckslash) for mixing interpolation and special sequences like #{}
puts "\#{my_var1} provides: #{my_var1}"

# Containers: Arrays and Hashes
# ARRAY
puts "Array examples"
ary1 = [1, 2, 3, 4]
puts ary1
puts "First element is #{ary1[0]}"
puts "Last element is #{ary1[-1]}"

# Arrays are MIXED CONTAINERS
ary2 = ["one", 2, 3.0, ary1]
puts ary2
# Printing DESCRIPTION of a value:
p ary2

# Hashes are like dictionaries
# i.e. pairs of key => value

hs1 = {'a' => 1, 'b' => 2, 'c' => 3}
p hs1
# Values are accessed with curly braces:
# hs1['a'] gives 1
puts "key 'a' has the value of #{hs1['a']}"

# For changing values use the assignment operator =
ary1[0] = "ZERO"
hs1['a'] = 'alpha' # same as hs1["a"]
p ary1
p hs1

# Symbols: very fast and efficient KIND OF string

my_sym1 = :one # that is DIFFERENT from "one"
my_sym2 = :two
hs2 = {:a => 1, :b=>2}
puts hs2[:a] # different from hs2["a"]
hs3 = {a:1, b:2, c:3}
p hs3

# Missing keys/indexes in Hashes/Arrays
puts hs3[:d]
hs3[:d] = 4.0
p hs3

puts ary1[4]
ary1[4] = 5
p ary1
ary1[10] = 11
p ary1

# CONDITIONALS: taking decisions
a = -100
if a >= 5 then
  puts "a is large"
elsif a < -10 then
  puts "a is very negative!"
elsif a < 0 then
  puts "a is negative"
else
  puts "a is OK"
end

if true then
  # do something
end

# postfix conditional syntax
puts a if a > 10

# negated conditional: unless
puts a unless a <= 10
puts a if !(a > 10)

# ternary operator: ?:
puts "a is #{a >= 0 ? 'positive' : 'negative'}"
sign = (a >= 0 ? 'positive' : 'negative')


# LOOPS: for, while, until

ary = [1, 2, 3, 4, 5, 6]
for e in ary do
  puts e
end

for i in 0..5 do
  puts "ary[#{i}] = #{ary[i]}"
end


# Ranges
rng = 1..10

 









