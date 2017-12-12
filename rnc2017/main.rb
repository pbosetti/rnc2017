#!/usr/bin/env ruby

require "./lib/rnc.rb"
require "./lib/machine2.rb"
require "./MTViewer/viewer.rb"

# Command line argument
if ARGV.size != 1 then
  puts "I need the name of the G-Code file as single argument!"
  exit -1
end

# Configuration hash
CFG = {
  file_name: ARGV[0], # G-code input file
  A: 200,              # Maximum acceleration
  D: 300,              # Maximum deceleration
  tq: 0.005,          # sampling time
  tolerance: 0.005    # tolerance for G00 end
}

# Machine tool origin
ORIGIN = RNC::Point[0,0,0]

# Instantiate the machine tool dynamics simulator
m = RNC::Machine.new
m.load_configs(["./lib/X.yaml", "./lib/Y.yaml", "./lib/Z.yaml"])
m.go_to ORIGIN
m.reset

# Instantiate the machine tool viewer (Viewer class)
viewer = Viewer::Link.new("./MTViewer/linux/MTviewer")
viewer.go_to ORIGIN

# Create parser object and parse G-Code file
parser = RNC::Parser.new(CFG).parse_file

colors = {A:1, M:2, D:3, R:0}
fmt = "%d %.3f %.5f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %d"

puts "=" * 79
puts "Press SPACEBAR in viewer window to start"
puts "=" * 79
loop until (viewer.run)


File.open("out.txt", "w") do |file|
  # Loop over all blocks
  file.puts "n t s r Xn Yn Zn X Y Z color"
  parser.each_block do |block, n|
    puts "#{n}: #{block.inspect}"
    case block.type
    when :G00
      m.go_to(block.target.map {|v| v / 1000.0})
      error = m.error * 1000.0
      t = 0
      while (error >= CFG[:tolerance]) do
        sleep_thread = Thread.new { sleep CFG[:tq] }
        state = m.step!
        state[:pos].map! {|v| v * 1000.0}
        error = m.error * 1000.0
        viewer.go_to state[:pos]
        # prepare data array to be written in output file
        dist = block.length - error
        data = [
          n, t, dist / block.length, dist,
          block.target,
          state[:pos],
          colors[:R]
        ].flatten
        # write formatted data
        file.puts fmt % data
        t += CFG[:tq]
        # wait for timing thread to end sleeping
        sleep_thread.join
      end
      file.puts "\n\n"
    when :G01
      # Loop within a block with the given timestep
      block.each_timestep do |t, cmd|
        # start a separate thread that waits for CFG[:tq] seconds
        sleep_thread = Thread.new { sleep CFG[:tq] }
        # update machine set-point
        m.go_to(cmd[:position].map {|v| v / 1000.0})
        # ask machine to forward-integrate the eq of dynamics for a timestep tq
        state = m.step!
        state[:pos].map! {|v| v * 1000.0}
        # update viewer position
        # save data to file
        viewer.go_to state[:pos]
        # prepare data array to be written in output file
        data = [
          n, t, cmd[:s], cmd[:r],
          cmd[:position],
          state[:pos],
          colors[cmd[:type]]
        ].flatten
        # write formatted data
        file.puts fmt % data
        # wait for timing thread to end sleeping
        sleep_thread.join
      end
      file.print "\n\n"
    else
      puts "Unknown ISO block type #{block.type}"
    end # case
  end # each_block
end # File.open

puts "=" * 79
puts "Press SPACEBAR in viewer window to start"
puts "=" * 79
loop while (viewer.run)
viewer.close
