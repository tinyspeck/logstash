
namespace "test" do
  task "default" => [ "dependency:gems" ] do
    require 'rspec/core'
    RSpec::Core::Runner.run(Rake::FileList["spec/**/*.rb"])
  end

  task "fail-fast" => [ "dependency:gems" ] do
    require 'rspec/core'
    RSpec::Core::Runner.run(["--fail-fast", *Rake::FileList["spec/**/*.rb"]])
  end
end

task "test" => [ "test:default" ] 
