#!/usr/bin/env ruby

require 'matrix'

module RNC
  def RNC.pbcopy(str)
    case RUBY_PLATFORM
    when /darwin/
      cmd = "pbcopy"
    when /linux/
      cmd = "xsel --clipboard --input"
    else
      return
    end
    IO.popen(cmd, "w") {|pb| pb.print str}
  end
  
  class Axis    
    attr_accessor :saturation
    attr_reader :Adt, :Bdt, :ts, :x, :y, :t, :name, :saturate
    def initialize(name="X", cfg=Machine::CFG[:X])
      @name = name
      @y            = [0,0,0]
      @Adt          = cfg[:Adt]
      @Bdt          = cfg[:Bdt]
      @ts           = cfg[:ts]
      self.friction = cfg[:static_fr]
      self.setpoint = 0.0
      @x            = Matrix.column_vector([0,0,0])
      @t            = 0.0
      @saturation   = cfg[:saturation]
      @saturate     = 0 
      @CC = Matrix[
          [-@Bdt[0,0], 0, 0],
          [-@Bdt[1,0], 1, 0],
          [-@Bdt[2,0], 0, 1]
        ]
      @DD = Matrix[
        [@Adt[0, 0] - 1, @Adt[0, 1], @Adt[0, 2], @Bdt[0, 1]], 
        [@Adt[1, 0],     @Adt[1, 1], @Adt[1, 2], @Bdt[1, 1]],
        [@Adt[2, 0],     @Adt[2, 1], @Adt[2, 2], @Bdt[2, 1]]
      ]
      @CCiDD = @CC.inverse * @DD
    end
    
    {current:0, angular_speed:1, position:2}.each do |method,i|
      define_method(method) { @x[i,0] }
    end
    
    def reset(p=0.0)
      @x = Matrix.column_vector([0.0,0.0,p])
      self.setpoint = p
    end
    
    def setpoint=(v)
      if self.setpoint != v then
        @y[0] = v
        @t = 0.0
      end
    end
    def setpoint; @y[0]; end
    
    def friction=(v)
      @y[1] = v
    end
    def friction; @y[1]; end
    
    def step(sp=nil)
      if sp then
        return @Adt * @x + @Bdt * Matrix.column_vector([sp, self.friction, 0])
      else
        return @Adt * @x + @Bdt * Matrix.column_vector(@y)
      end
    end
    
    def step!
      state = self.step
      ratio = @saturation / state[0,0]
      @saturate = (ratio <=> 0)
      if ratio.abs <= 1.0 then
        current = @saturate * @saturation
        tmp = @CCiDD * Matrix.column_vector([current, self.angular_speed, self.position, self.friction])
        state = self.step(tmp[0,0])
      else
        @saturate = 0
      end
      @t += @ts
      @x = state
    end
    
    def error
      self.position - self.setpoint
    end

  end #Axis
  
  
  class Machine
    CFG = {
      X:{ # 500 kg
        Adt:Matrix[
          [-0.150589970960392,-1.65032704606258,-77617.1711920005],
          [0.0252862900233449,0.165329364278568,-37204.9990952708],
          [1.63857112327214e-07,2.38902084955719e-06,0.925427156303841]
        ],
        Bdt:Matrix[
          [77617.1711931407,2.55958224116680,0.0],
          [37204.9990952707,-0.695789878753393,0.0],
          [0.0745728436903497,-1.77187139759262e-06,0.0]
        ],
        ts:0.005,
        static_fr:0.0,
        saturation:100.0
      },
      Y:{ # 250 kg
        Adt:Matrix[
          [-0.153739160218528,-1.49803063563595,-70754.6174212963],
          [0.0242805579744530,0.125922328757726,-38942.6372810216],
          [1.71509964962892e-07,2.28705311522964e-06,0.920820303250515]
        ],
        Bdt:Matrix[
          [70754.6174219752,2.68287263483906,0.0],
          [38942.6372810216,-0.720997300919170,0.0],
          [0.0791796967448381,-1.87309925223557e-06,0.0]
        ],
        ts:0.005,
        static_fr:0.0,
        saturation:70.0
      },
      Z:{ # 50 kg
        Adt:Matrix[
          [-0.155700989381150,-1.36481355696014,-64753.4197621014],
          [0.0231083366208011,0.0924199905390268,-40416.0699509332],
          [1.77999211794536e-07,2.19641470122422e-06,0.916724615993192]
        ],
        Bdt:Matrix[
          [64753.4197604777,2.78804789212347,0.0],
          [40416.0699509332,-0.741307270631965,0.0],
          [0.0832753840151895,-1.96204688781656e-06,0.0]
        ],
        ts:0.005,
        static_fr:0.0,
        saturation:70.0
      }
    }
    
    attr_reader :x, :y, :z, :cfg
    def initialize(cfg=CFG)
      @cfg = cfg
      self.set_from_cfg
    end
    
    def set_from_cfg
      @x = Axis.new("X", @cfg[:X])
      @y = Axis.new("Y", @cfg[:Y])
      @z = Axis.new("Z", @cfg[:Z])
    end
    
    def load_configs(files)
      require 'yaml'
      @cfg = {}
      files.each do |file|
        d = File.open(file) {|f| YAML.load f}
        name = d['axis'].upcase.to_sym
        @cfg[name] = {}
        @cfg[name][:Adt] = Matrix[*d['mat']['Adt']]
        @cfg[name][:Bdt] = Matrix[*d['mat']['Bdt']]
        @cfg[name][:ts] = d['params']['ts']
        @cfg[name][:static_fr] = d['params']['static_fr']
        @cfg[name][:saturation] = d['params']['saturation']
      end
      self.set_from_cfg
    end
    
    def dump_to_file(file)
      require "yaml"
      File.open(file, "w") { |file| YAML.dump(@cfg, file) }
    end
  
    def reset
      @x.reset
      @y.reset
      @z.reset
    end
        
    def setpoint
      [@x, @y, @z].map {|a| a.setpoint}
    end
    
    def go_to(p)
      @x.setpoint = p[0]
      @y.setpoint = p[1]
      @z.setpoint = p[2]
    end
    
    def step!
      @x.step!
      @y.step!
      @z.step!
      return {pos:[@x.position, @y.position, @z.position]}
    end
  
    def error
      return Math::sqrt(@x.error**2 + @y.error ** 2 + @z.error**2)
    end
    
  end #Machine
  
end #RNC

if $0 == __FILE__ then
  require 'pry'
  m = RNC::Machine.new
  # m.load_configs %w(lib/X.yaml lib/Y.yaml lib/Z.yaml)
  
  ax = m.x
  ax.setpoint = 1.0
  output = %w(t current w pos error saturate) * " " + "\n"
  loop do
    binding.pry if ARGV[0]
    ax.step!
    vars = [ax.t, ax.current, ax.angular_speed, ax.position, ax.error]
    fmt = ("%10.3f " * vars.length)
    output += fmt % vars
    output += "#{ax.saturate}\n"
    break if ax.t >= 2.0
  end
  RNC.pbcopy output
  puts "Done. Data are in pasteboard."
end
