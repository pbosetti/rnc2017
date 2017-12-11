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
  file_name: ARGV[0],
  A: 10,
  D: 15,
  tq: 0.005
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

File.open("out.txt", "w") do |file|
  # Loop over all blocks
  file.puts "n t s r Xn Yn Zn X Y Z color"
  parser.each_block do |block, n|
    puts "#{n}: #{block.inspect}"
    case block.type
    when :G00
      next
    when :G01
      # Loop within a block with the given timestep
      block.each_timestep do |t, cmd|
        # update machine set-point
        m.go_to(cmd[:position].map {|v| v / 1000.0})
        # ask machine to forward-integrate the eq of dynamics for a timestep tq
        state = m.step!
        state[:pos].map! {|v| v * 1000.0}
        # update viewer position
        viewer.go_to state[:pos]
        # save data to file
        data = [
          n, t, cmd[:s], cmd[:r],
          cmd[:position],
          state[:pos],
          colors[cmd[:type]]
        ].flatten
        file.puts fmt % data

      end
      file.print "\n\n"
    end # case
  end # each_block
end # File.open


viewer.close
