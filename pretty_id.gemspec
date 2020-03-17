
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pretty_id/version"

Gem::Specification.new do |spec|
  spec.name          = "prettyid"
  spec.version       = PrettyId::VERSION
  spec.authors       = ["Pavel Gabriel"]
  spec.email         = ["alovak@gmail.com"]
  spec.licenses      = ['MIT']

  spec.summary       = %q{Generate Stripe-like ids for your ActiveRecord models}
  spec.description   = %q{Generate Stripe-like ids for your ActiveRecord models}

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3", ">= 1.4.2"

  spec.add_dependency "activerecord", ">= 4.2.0"
  spec.add_dependency "activesupport", ">= 4.2.0"
end
