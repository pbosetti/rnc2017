require "rake/clean"

case RUBY_PLATFORM
when /darwin/
  OS = :mac
  CC = "gcc"
  GCC = "gcc"
when /linux/
  OS = :linux
  CC = "clang"
  GCC = "clang"
else
  raise "Platform not supported!"
end
puts "Running on #{OS} (#{RUBY_PLATFORM})"

src_dir   = 'MTViewer/viewer'
proj_dir  = 'MTViewer'
case OS
when :mac
  src = FileList["#{src_dir}/*.cpp", "#{src_dir}/../AntTweakBar/*.c*"]
  src.delete_if {|e| e =~ /X11/}
when :linux
  src = FileList["#{src_dir}/*.cpp", "#{src_dir}/../AntTweakBar/*.c*"]
#  src.delete_if {|e| e =~ //}
end
obj       = src.ext('o')
exec_name = "MTViewer/#{OS.to_s}/MTviewer"

CLEAN.include("#{src_dir}/*.o")
CLEAN.include("#{src_dir}/../AntTweakBar/*.o")
CLOBBER.include(exec_name)

rule ".o" => [".c"] do |t|
  case OS
  when :mac
    sh "#{GCC} -D_MACOSX -Os -I/usr/include -I./MTViewer/AntTweakBar -o #{t.name} -c #{t.source}"
  when :linux
    sh "#{CC} -D_UNIX -Os -I./MTViewer/AntTweakBar -I/usr/include/GL -I/usr/local/include -I/usr/X11R6/include -I/usr/include -o #{t.name} -c #{t.source}"
  end
end

rule ".o" => [".cpp"] do |t|
  case OS
  when :mac
    sh "#{GCC} -D_MACOSX -Os -I/usr/include -I./MTViewer/AntTweakBar -o #{t.name} -c #{t.source}"
  when :linux
    sh "#{GCC} -std=c++11 -fpermissive -D_UNIX -Os -I./MTViewer/AntTweakBar -I/usr/include/GL -I/usr/local/include -I/usr/X11R6/include -I/usr/include -o #{t.name} -c #{t.source}"
  end
end

file exec_name => obj do
  case OS
  when :mac
    sh "#{GCC} -lstdc++ -framework AppKit -framework GLUT -framework OpenGL -o #{exec_name} #{obj}"
  when :linux
    sh "#{GCC} -lstdc++ -lX11 -lGLEW -lGL -lGLU -lglut -lpthread -lm -o #{exec_name} #{obj}"
  end
end


desc "Compile with Xcode"
task :xcbuild do
  sh "cd #{proj_dir}; xcodebuild -scheme \"MTviewer\" -configuration Release"
end

desc "Compile with CC"
task :build do
  case OS
  when :mac
    Rake::Task["xcbuild"].invoke
  when :linux
    Rake::Task[exec_name].invoke
  end
end

task :gcc => exec_name

desc "Build all"
task :all => :build
