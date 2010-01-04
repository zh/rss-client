require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  project_name = "rss-client"
  rdoc_files = %w[
  lib
  README.rdoc
  LICENSE
  ]
  rdoc_opts  = %w[
  --line-numbers
  --inline-source
  --all
  --quiet
  --title rss-client:\ Fetching\ and\ parsing\ RSS\ feeds\ with\ easy
  --main README.rdoc
  --exclude "^(_darcs|.hg|.svn|spec|bin|pkg)/"
  ]

  Jeweler::Tasks.new do |gem|
    gem.name = project_name
    gem.summary = %Q{Fetching and parsing RSS feeds with easy}
    gem.description = %Q{Ruby library for fetching (http-access2) and parsing (feed-normalizer) RSS (and Atom) feeds.}
    gem.email = "zh@zhware.net"
    gem.homepage = "http://github.com/zh/#{project_name}"
    gem.authors = ["Stoyan Zhekov"]
    gem.rubyforge_project = project_name
    gem.platform = Gem::Platform::RUBY
    gem.files = (rdoc_files + %w[Rakefile] + Dir["{bin,lib,rake_tasks,spec}/**/*"]).uniq
    gem.test_files = Dir['spec/spec_*.rb']
    gem.require_path = "lib"
    gem.bindir = "bin"
    gem.executables = ['rssclient']
    gem.default_executable = 'rssclient'
    gem.has_rdoc = true
    gem.extra_rdoc_files = rdoc_files
    gem.rdoc_options = rdoc_opts
    gem.add_dependency('feed-normalizer', '>= 1.4.0')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

task :default => :spec
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new {|t| t.spec_opts = ['--color']}

task :test => :check_dependencies

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'spec'
    test.pattern = 'spec/**/*_spec.rb'
    test.verbose = true
    test.rcov_opts = %w{--exclude rdoc\/,pkg\/,spec\/}
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rss-client #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
