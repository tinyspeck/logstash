def staging
  "build/staging"
end

namespace "artifact" do
  require "logstash/environment"
  package_files = [
    "LICENSE",
    "CHANGELOG",
    "CONTRIBUTORS",
    "{bin,lib,spec,locales}/{,**/*}",
    "patterns/**/*",
    "vendor/elasticsearch/**/*",
    "vendor/collectd/**/*",
    "vendor/jruby/**/*",
    "vendor/kafka/**/*",
    "vendor/geoip/**/*",
    File.join(LogStash::Environment.gem_home.gsub(Dir.pwd + "/", ""), "{gems,specifications}/**/*"),
    "Rakefile",
    "rakelib/*",
  ]
  
  desc "Build a tar.gz of logstash with all dependencies"
  task "tar" => ["vendor:elasticsearch", "vendor:collectd", "vendor:jruby", "vendor:gems"] do
    Rake::Task["dependency:archive-tar-minitar"].invoke
    require "zlib"
    require "archive/tar/minitar"
    require "logstash/version"
    tarpath = "build/logstash-#{LOGSTASH_VERSION}.tar.gz"
    tarfile = File.new(tarpath, "wb")
    gz = Zlib::GzipWriter.new(tarfile, Zlib::BEST_COMPRESSION)
    tar = Archive::Tar::Minitar::Output.new(gz)
    package_files.each do |glob|
      Rake::FileList[glob].each do |path|
        Archive::Tar::Minitar.pack_file(path, tar)
      end
    end
    tar.close
    gz.close
    puts "Complete: #{tarpath}"
  end

  desc "Build an RPM of logstash with all dependencies"
  task "rpm" do
    Rake::Task["dependency:fpm"].invoke
    require "fpm/package/dir"
    require "fpm/package/rpm"

    input = FPM::Package::Dir.new

    package_files.each do |path|
      package.input("#{path}=/opt/logstash/#{path}")
    end

    # Do any platform-specific stuff

    # Convert it to an rpm
    package = package.convert(FPM::Package::RPM)
    begin
      output = "NAME-VERSION.ARCH.rpm"
      package.output(rpm.to_s(output))
    ensure
      rpm.cleanup
    end
  end

  desc "Build an RPM of logstash with all dependencies"
  task "deb" do
    Rake::Task["dependency:fpm"].invoke
  end
end

