#!/usr/bin/env ruby 
# viewer.rb

# Created by Paolo Bosetti on 2012-12-12.
# Copyright (c) 2012 University of Trento. All rights reserved.
require "ffi"

module Viewer
  case RUBY_PLATFORM
  when /darwin/
    OS = :mac
  when /linux/
    OS = :linux
  else
    raise "Platform not supported!"
  end

  extend FFI::Library
  if OS == :mac
    # Workaround for El Capitan
    ffi_lib '/usr/lib/libc.dylib'
  else
    ffi_lib FFI::Library::LIBC
  end
  SHM_KEY = 3333
  SHM_RND = 020000
  
  attach_function :shmget, [:int, :int, :int], :int
  attach_function :shmat,  [:int, :int, :int], :pointer
  attach_function :shmdt,  [:pointer], :int
  attach_function :ftok,   [:string, :int], :int
  
  class Command < FFI::Struct
    layout(
      :flag, :char,
      :run,  :bool,
      :coord, [:float, 3],
      :offset, [:float, 3],
      :tool_length, :float,
      :tool_radius, :float
    )
    def flag=(s); self[:flag] = s[0].ord; end
    def flag; self[:flag].chr; end
    def coord=(ary)
      3.times { |i| self[:coord][i] = ary[i].to_f }
    end
    def coord
      (0..2).map { |i| self[:coord][i] }
    end
    def offset=(ary)
      3.times { |i| self[:offset][i] = ary[i].to_f }
    end
    def offset
      (0..2).map { |i| self[:offset][i] }
    end
  end
  
  class Link
    attr_accessor :cmd, :mem, :viewer_pid
    def initialize(viewer_path)
      raise ArgumentError, "#{viewer_path} does not exists!" unless File.executable? viewer_path
      fname = File.expand_path(__FILE__)
      key = Viewer.ftok(File.expand_path($0), Process.uid)
      exec("#{viewer_path} #{key}") if (@viewer_pid = fork).nil?
      begin
        if (@shm_id = Viewer::shmget(key, Viewer::Command.size/8, 0666)) == -1
          warn "shmget error: #{Errno.constants[FFI::errno]}"
          raise RuntimeError
        end
      rescue RuntimeError
        retry
      end
      @mem               = Viewer::shmat(@shm_id, 0, SHM_RND)
      @cmd               = Command.new @mem
      @cmd.flag          = "-"
      @cmd[:run]         = false
      @cmd[:tool_length] = 30
      @cmd[:tool_radius] = 5
      @cmd.coord         = [0,0,0]
    end
    
    def go_to(ary=[0,0,0])
      @cmd.coord = ary
      @cmd.flag = "*"
    end
    
    def set_offset(ary=[0,0,0])
      @cmd.offset = ary
      @cmd.flag = "*"
    end
    
    def x=(x)
      @cmd[:coord][0] = x.to_f
      @cmd.flag = "*"
    end
    def y=(y)
      @cmd[:coord][0] = y.to_f
      @cmd.flag = "*"
    end
    def z=(z)
      @cmd[:coord][0] = z.to_f
      @cmd.flag = "*"
    end
    def run
      @cmd[:run]
    end
    def close
      Process.kill :HUP, @viewer_pid
      Viewer.shmdt(@mem)
    end
  end
end

if $0 == __FILE__ then
  require "pry"
  
  l = Viewer::Link.new("./#{Viewer::OS.to_s}/MTviewer")
  binding.pry
  l.close
end
