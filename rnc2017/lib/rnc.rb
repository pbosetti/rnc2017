#!/usr/bin/env ruby

module RNC
  AXES = {X:0, Y:1, Z:2}
  COMMANDS = [:G00, :G01]
  # Representation of a 3-D coordinate (child of Array)
  # Also support indexing as pt[:X], pt[:Y], pt[:Z]
  # Also support common operations: distance, modal,
  # projections
  class Point < Array
    def self.[](x=nil, y=nil, z=nil)
      pt = Point.new
      pt[0] = x
      pt[1] = y
      pt[2] = z
      return pt
    end

    # supporting pt1 - pt2
    def -(other)
      raise "Operand must be a RNC::Point" unless other.kind_of? Point
      return Math::sqrt(
        (self[0] - other[0]) ** 2 +
        (self[1] - other[1]) ** 2 +
        (self[2] - other[2]) ** 2
      )
    end

    def delta(other)
      raise "Operand must be a RNC::Point" unless other.kind_of? Point
      result = Point[]
      [0,1,2].each {|ax| result[ax] = self[ax] - other[ax]}
      return result
    end

    # if pt0 = Point[0,1,1], pt1 = Point[0,nil,2]
    # then pt1.modal!(pt0) is Point[0,1,2]
    def modal!(other)
      [0,1,2].each do |ax|
        self[ax] = other[ax] unless self[ax]
      end
    end

    # supports pt[:X], or pt[0], or pt["X"]
    def [](idx)
      super(remap_index(idx))
    end

    # supports pt[:X] = 10
    def []=(idx, new_value)
      super(remap_index(idx), new_value)
    end

    # ONLY RETURN A STRING DESCRIPTION
    # of current instance
    def inspect
      return "[#{self[:X]} #{self[:Y]} #{self[:Z]}]"
    end

    private
    def remap_index(idx)
      case idx
      when Numeric
        return idx.to_i
      when String
        return AXES[idx.upcase.to_sym]
      when Symbol
        return AXES[idx]
      else
        raise "Point index must be a number or a String or a Symbol!"
      end
    end


  end # class Point

  # represents a single line G-code instruction
  class Block
    attr_reader :line
    attr_reader :start, :target, :feed_rate, :spindle_rate
    attr_reader :length, :delta, :type
    attr_accessor :profile, :dt

    def initialize(l='G00 X0 Y0 Z0 F1000 S1000')
      @start = Point[]
      @target = Point[]
      @feed_rate = nil
      @spindle_rate = nil
      @type = nil
      @length = nil
      @delta = Point[]
      @profile = nil
      @dt = nil
      self.line = l
    end

    def line=(str)
      @line = str.upcase
      self.parse
    end

    def parse
      words = @line.split # "1,2,3".split(',') => ["1", "2", "3"]
      @type = words.shift.to_sym # [1,2,3].shift => 1, and array becomes [2,3]
      unless COMMANDS.include? @type then
        raise "unsupported command #{@type}!"
      end
      words.each do |w|
        cmd = w[0]
        arg = w[1..-1].to_f
        case cmd
        when 'F'
          @feed_rate = arg
        when 'S'
          @spindle_rate = arg
        when 'X', 'Y', 'Z'
          @target[cmd] = arg
        else
          raise "Unsupported G-code command #{cmd}"
        end
      end
    end

    def modal!(prev_block)
      raise "Need a Block!" unless prev_block.kind_of? Block
      @start = prev_block.target
      @target.modal!(@start)
      @feed_rate = prev_block.feed_rate
      @spindle_rate = prev_block.spindle_rate
      @length = @target - @start
      @delta = @target.delta(@start)
      return self
    end

    def inspect
      return "[#{@type} #{@target} L#{@length} F#{@feed_rate} S#{@spindle_rate}]"
    end

  end #class Block

  # Interface to a G-code file: reads the file
  # and provides a representation of its content
  # as an Array of G-code Blocks
  class Parser

  end # class Parser

  # Calculates a velocity profile for a given motion,
  # either rapid (G00) or linear motion (G01)
  class Profiler

  end # class Profiler

  # Uses velocity profiles for synchronizing the motion of
  # machine axes
  class Interpolator

  end # class Interpolator

end # module RNC
