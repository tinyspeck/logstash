
rule ".rb" => ".treetop" do |task, args|
  # TODO(sissel): Treetop 1.5.x doesn't seem to work well, but I haven't
  # investigated what the cause might be. -Jordan
  Rake::Task["gem:require"].invoke("treetop", "~> 1.4.0", ENV["GEM_HOME"])
  require "treetop"
  compiler = Treetop::Compiler::GrammarCompiler.new
  compiler.compile(task.source, task.name)
  puts "Compiling #{task.source}"
end

namespace "build" do
  desc "Compile the config grammar"
  task "grammar" => "build/staging/lib/logstash/config/grammar.rb"

  desc "Build everything"
  task "all" => "grammar"
end

namespace "clean" do
  task "grammar" do
    "build/staging/lib/logstash/config/grammar.rb".tap do |path|
      rm path if File.exist?(path)
    end
  end
  task "all" => "grammar"
end
