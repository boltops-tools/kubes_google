require_relative 'lib/kubes_google/version'

Gem::Specification.new do |spec|
  spec.name          = "kubes_google"
  spec.version       = KubesGoogle::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tung@boltops.com"]

  spec.summary       = "Kubes Google Helpers Library"
  spec.homepage      = "https://github.com/boltops-tools/kubes_google"
  spec.license       = "Apache2.0"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "google-cloud-container"
  spec.add_dependency "google-cloud-resource_manager"
  spec.add_dependency "google-cloud-secret_manager"
  spec.add_dependency "memoist"
  spec.add_dependency "zeitwerk"

  spec.add_development_dependency "kubes"
end
