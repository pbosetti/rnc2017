#!/usr/bin/env ruby

require "./lib/rnc.rb"

# development tests

# Configuration hash
cfg = {
  file_name: "test.iso",
  A: 1000,
  D: 1500,
  tq: 0.005
}

# Create parser object and parse G-Code file
parser = RNC::Parser.new(cfg)
parser.parse_file
p parser

# Prepare the Interpolator instance
interp = RNC::Interpolator.new(cfg)

# Loop over all blocks
parser.each_block do |block, n|
  p [n, block]
  # Set current block in the Interpolator
  interp.block = block
  # Skip (for now) rapid blocks
  next if block.type == :G00
  # Loop within a block with the given timestep
  interp.each_timestep do |t, cmd|
    # CUSTOMIZE HERE: save the relevant info into a text file
    # and use it for plotting
    p [n, t, cmd]
  end
end
