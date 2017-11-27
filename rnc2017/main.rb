#!/usr/bin/env ruby

require "./lib/rnc.rb"

# development tests:

pt1 = RNC::Point[0,0,0]
pt2 = RNC::Point[1,1,1]
pt3 = RNC::Point[5,nil,10]
puts pt1 - pt2
pt3.modal!(pt2)
p pt3
p pt3.delta(pt2)

# Block tests
b0 = RNC::Block.new
b1 = RNC::Block.new('G01 x200 F2000')
p b0
p b1
b1.modal!(b0)
p b1
