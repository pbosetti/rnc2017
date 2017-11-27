#!/usr/bin/env ruby -wKU

class String
  ANSI_COLORS = {
    black: 30,
    red: 31,
    green: 32,
    brown: 33,
    blue: 34,
    magenta: 35,
    cyan: 36,
    gray: 37
  }

  def fg(c)
    return colorize(ANSI_COLORS[c] || 0)
  end

  def bg(c)
    return colorize((ANSI_COLORS[c] || 0) + 10)
  end

  private
  def colorize(n)
    "\e[#{n}m#{self}\e[0m"
  end


end
