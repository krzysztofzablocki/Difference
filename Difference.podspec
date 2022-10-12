Pod::Spec.new do |s|
  s.name         = "Difference"
  s.version      = "1.0.2"
  s.summary      = "Better way to identify whats different between 2 instances."
  s.description  = <<-DESC
    Better way to identify whats different between 2 instances. Based on Mirror API.
  DESC
  s.homepage     = "https://github.com/krzysztofzablocki/Difference"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Krzysztof Zablocki" => "krzysztof.zablocki@pixle.pl" }
  s.ios.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "12.4"
  s.source       = { :git => "https://github.com/krzysztofzablocki/Difference.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
  s.swift_version = '5.0'
end
