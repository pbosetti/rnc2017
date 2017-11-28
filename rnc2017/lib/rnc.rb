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

    def round(n=3)
      self.class.new([:X, :Y, :Z].map {|x| self[x].round(n) if self[x]})
    end

    # ONLY RETURN A STRING DESCRIPTION
    # of current instance
    def inspect
      pt  = self.round
      return "[#{pt[:X] || '-'} #{pt[:Y] || '-'} #{pt[:Z] || '-'}]"
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
      @length = 0.0
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
      #@feed_rate = prev_block.feed_rate unless @feed_rate
      # other possibility:
      @feed_rate    ||= prev_block.feed_rate
      @spindle_rate ||= prev_block.spindle_rate
      @length = @target - @start
      @delta = @target.delta(@start)
      return self
    end

    def inspect
      return "[#{@type} #{@target} L#{@length.round(3)} \
F#{@feed_rate || '-'} S#{@spindle_rate || '-'}]"
    end

  end #class Block

  # Interface to a G-code file: reads the file
  # and provides a representation of its content
  # as an Array of G-code Blocks
  class Parser
    attr_reader :blocks, :file_name

    def initialize(cfg)
      @blocks = [Block.new()]
      @file_name = cfg[:file_name]
      @profiler = Profiler.new(cfg)
    end

    def parse_file
      File.foreach(@file_name) do |line|
        next if line.length <= 1
        next if line[0] == '#'
        b = Block.new(line).modal!(@blocks.last)
        b.profile  = @profiler.velocity_profile(b.feed_rate, b.length)
        # later on we will call it as b.profile.call(time)
        b.dt = @profiler.dt
        @blocks << b
      end
    end

    def each_block
      raise "I need a block!" unless block_given?
      @blocks.each_with_index do |b, i|
        yield b, i
      end
    end

    def inspect
      result = ""
      self.each_block do |block, index|
        result << "N#{index}: #{block.inspect}\n"
      end
      return result
    end

  end # class Parser

  # Calculates a velocity profile for a given motion,
  # either rapid (G00) or linear motion (G01)
  class Profiler
    attr_reader :times, :accel, :feed_rate, :dt
    def initialize(cfg)
      raise "Need a configuration Hash" unless cfg.kind_of? Hash
      [:A, :D, :tq].each do |k|
        raise "#{k} key is missing" unless cfg[k]
      end
      @cfg = cfg
    end

    def velocity_profile(f_m, l)
      f_m /= 60.0
      l = l.to_f
      # Nominal time intervals before quantization:
      dt_1 = f_m / @cfg[:A]
      dt_2 = f_m / @cfg[:D]
      dt_m = l / f_m - (dt_1 + dt_2) / 2.0

      if dt_m > 0 then # trapezoid
        q = quantize(dt_1 + dt_m + dt_2)
        dt_m += q[1] # this is dt_m*
        f_m = (2 * l) / (dt_1 + dt_2 + 2 * dt_m) # this is f_m*
      else # triangular profile
        dt_1 =  Math::sqrt(2 * l / (@cfg[:A] + @cfg[:A] ** 2 / @cfg[:D]))
        dt_2 = dt_1 * @cfg[:A] / @cfg[:D]
        q = quantize(dt_1 + dt_2)
        dt_m = 0
        dt_2 += q[1]
        f_m = 2 * l / (dt_1 + dt_2)
      end
      a = f_m / dt_1 # this is a*
      d = -(f_m / dt_2)

      @times = [dt_1, dt_m, dt_2]
      @accel = [a, d]
      @feed_rate = f_m
      @dt = q[0]

      return proc do |t|
        r = 0.0
        if t < dt_1 then #aceleration
          type = :A
          r = a * (t ** 2) / 2.0
        elsif t < (dt_1 + dt_m) then # maintenance
          type = :M
          r = f_m * (dt_1 / 2.0 + (t - dt_1))
        else #deceleration
          type = :D
          t_2 = dt_1 + dt_m
          r = f_m * dt_1 / 2.0 + f_m * (dt_m + t - t_2) +
              d / 2.0 * (t ** 2 + t_2 ** 2) -d * t * t_2
        end
        {s: r / l, r: r, type: type}
      end


    end

    private
    def quantize(t)
      if (t % @cfg[:tq]) == 0 then
        result = [t, 0.0]
      else
        result = []
        result[0] = ((t / @cfg[:tq]).to_i + 1) * @cfg[:tq]
        result[1] = result[0] - t
      end
      return result
    end


  end # class Profiler

  # Uses velocity profiles for synchronizing the motion of
  # machine axes
  class Interpolator
    attr_accessor :block

    def initialize(cfg)
      @cfg = cfg
      @block = nil
    end

    def eval(t)
      raise "invalid block" unless @block.kind_of? Block
      result = {}
      case @block.type
      when :G00
        result[:position] = @block.target
        result[:s] = 0.0
        result[:type] = :R
      when :G01
        if (0..@block.dt).include? t then
          result = @block.profile.call(t)
          result[:position] = Point[]
          [:X, :Y, :Z].each do |axis|
            result[:position][axis] = @block.start[axis] + result[:s] * @block.delta[axis]
          end
        else
          result = nil
        end
      else
        raise "Unsupported G-Code command #{@block.type}!"
      end
      return result
    end

    def each_timestep
      t = 0.0
      while (cmd = self.eval(t)) do
        break if @block.length == 0
        yield t, cmd
        t += @cfg[:tq]
      end
    end

  end # class Interpolator

end # module RNC
