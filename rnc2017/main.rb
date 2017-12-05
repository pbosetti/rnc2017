#!/usr/bin/env ruby

require "./lib/rnc.rb"

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

# Create parser object and parse G-Code file
parser = RNC::Parser.new(CFG).parse_file

colors = {A:1, M:2, D:3, R:0}

File.open("out.txt", "w") do |file|
  # Loop over all blocks
  file.puts "n t s r X Y Z color"
  parser.each_block do |block, n|
    p [n, block]
    # Skip (for now) rapid blocks
    next if block.type == :G00
    # Loop within a block with the given timestep
    block.each_timestep do |t, cmd|
      # CUSTOMIZE HERE: save the relevant info into a text file
      # and use it for plotting
      file.puts "%d %.3f %.5f %.3f %.3f %.3f %.3f %d" % [n, t, cmd[:s], cmd[:r], cmd[:position][:X], cmd[:position][:Y], cmd[:position][:Z], colors[cmd[:type]]]
    end
    file.print "\n\n"
  end
end
