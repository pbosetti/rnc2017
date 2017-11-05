#!/usr/bin/env ruby

# Inheritance

module Geometry
  class RegularPolygon
    attr_reader :side_number
    attr_accessor :side_length
    
    def initialize(side_length, side_number=3)
      @side_length = side_length
      @side_number = side_number
    end
    
    def perimeter
      return @side_length * @side_number
    end
    
    def inspect
      "This is a #{self.class} with side length of #{@side_length}"
    end
    
  end # RegularPolygon


  class Triangle < RegularPolygon
    def initialize(l)
      super(l, 3)
    end
  end
  
  class FilledTriangle < Triangle
  end 


  class Square < RegularPolygon
    def initialize(l)
      super(l, 4)
    end
  end


  class Pentagon < RegularPolygon
    def initialize(l)
      super(l, 5)
    end
  end
  
  class Hash
  
  end
  
end # module Geometry


t = Geometry::Triangle.new(10)
s = Geometry::Square.new(12)
p = Geometry::Pentagon.new(5)

[t, s, p].each {|e| p e}

puts "===ITERATORS==="

10.times do |i|
  puts "#{i}"
end

puts

ary = %w{uno due tre quattro}
ary.each_with_index do |e, i|
  puts "#{i}: #{e}"
end
p ary.map {|e| e.upcase}

hsh = {one:1, two:2, three:3, four:4}
hsh.each do |k, v|
  puts "#{k}: #{v}"
end

ary = (0..19).to_a
ary.map! {|e| e * 2}
p ary

puts ary[1..-1].inject(1) {|s, e| s * e}











