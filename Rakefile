require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'benchmark'
require 'pretty_id'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :bm do
  n = 1_000_000

  class One
    def self.id_prefix
      'one'
    end
  end

  generator = PrettyId::Generator.new(One.new)

  Benchmark.bm(20) do |x|
    x.report("PrettyId::Generator#id:")   { n.times { generator.id } }
  end
end
