#!/usr/bin/env ruby

require "./lib/rnc.rb"

# development tests:

parser = RNC::Parser.new("test.iso")
parser.parse_file
p parser
