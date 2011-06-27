# Move this to a more appropriate place later
module Vegas
  def self.root(*args)
    if args.length == 0
      @__ROOT ||= File.expand_path(File.dirname(__FILE__))
    else
      File.join(Vegas.root, *args)
    end
  end
end

namespace :doc do
  desc 'Generate the project report PDF'
  task :generate do
    puts "Generating the project report..."
    system('pdflatex', "-output-directory=#{Vegas.root('doc')}", Vegas.root('doc', 'project.tex'))
  end

  desc 'Remove generated tex intermediate files'
  task :clean do
    garbage = ['aux', 'log', 'pdf'].map {|ext| Vegas.root('doc', "*.#{ext}")}
    rm FileList[*garbage]
  end
end

task :doc => 'doc:generate'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

