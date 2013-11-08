# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
    spec.name          = "eaglecad"
    spec.version       = '0'
    spec.authors       = ["Brandon Fosdick"]
    spec.email         = ["bfoz@bfoz.net"]
    spec.description   = %q{Everything you need to bend Eagle CAD projects to your will}
    spec.summary       = %q{Read and write Eagle CAD files}
    spec.homepage      = "http://github.com/bfoz/eaglecad-ruby"
    spec.license       = "BSD"

    spec.files         = `git ls-files`.split($/)
    spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
    spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
    spec.require_paths = ["lib"]

    spec.add_development_dependency "bundler", "~> 1.3"
    spec.add_development_dependency "rake"

    spec.add_dependency 'geometry', '~> 6'
end
