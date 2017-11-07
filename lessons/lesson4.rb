#!/usr/bin/env ruby -wKU

class String
  ANSI_COLORS = {
    black:      30,
    red:        31,
    green:      32,
    brown:      33,
    blue:       34,
    magenta:    35,
    cyan:       36,
    gray:       37
  }
  # enable this writing: "some text".fg(:red)

  def fg(c)
    return self unless ANSI_COLORS[c]
    return colorize(ANSI_COLORS[c])
  end

  def bg(c) # c is something like :red, :green, :blue
    return self unless ANSI_COLORS[c]
    return colorize(ANSI_COLORS[c]+10)
  end

  private
  def colorize(cn)
    return "\e[#{cn}m#{self}\e[0m"
  end

end


class Chalk
  attr_accessor :blackboard, :length
  attr_reader :color
  @@blackboard = []

  # Class methods
  def self.blackboard
    return @@blackboard
  end

  def self.cleanup
    @@blackboard = []
  end

  # Instance methods
  def initialize(length=50, color=:white)
    raise ArgumentError, "length: got #{length.class}, expecting Fixnum" unless length.kind_of? Fixnum
    raise ArgumentError, "color: got #{color.class}, expecting Symbol" unless color.kind_of? Symbol
    @length = length
    @color = color
  end

  def inspect # MUST return a String
    return "Current chalk is #{@color} of length #{@length}".fg(@color)
  end

  # returns a string and decrements @lenght accordingly
  def writings(str)
    str = str.inspect unless str.kind_of? String

    return "*" if @length < 10
    @length -= str.length
    @@blackboard << str.fg(@color)
    return str.fg(@color)
  end

  # writes to the console
  def write(str)
    puts self.writings(str)
  end # write

end # class Chalk
