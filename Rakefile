begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SimpleTokenAuthentication'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


Bundler::GemHelper.install_tasks


begin
  require 'inch/rake'

  Inch::Rake::Suggest.new(:inch) do |suggest|
    suggest.args << "--private"
    suggest.args << "--pedantic"
  end
rescue LoadError
  desc 'Inch rake task not available'
  task :inch do
  abort 'Inch rake task is not available. Be sure to install inch as a gem or plugin'
  end
end

begin
  require 'rspec/core/rake_task'

  desc 'Provide private interfaces documentation'
  RSpec::Core::RakeTask.new(:spec)

  namespace :spec do
    desc 'Provide public interfaces documentation'
    RSpec::Core::RakeTask.new(:public) do |t|
      t.rspec_opts = "--tag public"
    end
  end

  namespace :spec do
    desc 'Provide private interfaces documentation for development purpose'
    RSpec::Core::RakeTask.new(:development) do |t|
      t.rspec_opts = "--tag protected --tag private"
    end
  end
rescue LoadError
  desc 'RSpec rake task not available'
  task :spec do
  abort 'RSpec rake task is not available. Be sure to install rspec-core as a gem or plugin'
  end
end

task default: ['spec:public', 'spec:development', :inch]
