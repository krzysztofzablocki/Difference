Pod::Spec.new do |s|
  s.name         = "Difference"
  s.version      = "0.2"
  s.summary      = "Better way to identify whats different between 2 instances."
  s.description  = <<-DESC
    Better way to identify whats different between 2 instances. Based on Mirror API.
  DESC
  s.homepage     = "https://github.com/krzysztofzablocki/Difference"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Krzysztof Zablocki" => "krzysztof.zablocki@pixle.pl" }
  s.social_media_url   = ""
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/krzysztofzablocki/Difference.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
