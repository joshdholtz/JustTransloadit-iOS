Pod::Spec.new do |s|
  s.name         = "JustTransloadit"
  s.version      = "0.0.1"
  s.summary      = "A simple library for Transloadit."
  s.description  = <<-DESC
                    A simple library for Transloadit using AFNetworing.
                   DESC
  s.homepage     = "https://github.com/joshdholtz/JustTransloadit-iOS"
  s.license      = 'MIT'
  s.author       = { "Josh Holtz" => "me@joshholtz.com" }
  s.source       = { :git => "https://github.com/joshdholtz/JustTransloadit-iOS.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '5.0'
  s.requires_arc = true

  s.public_header_files = 'Classes/*.h'
  s.source_files = 'Classes/*'

  s.dependency 'AFNetworking', '~> 2.2.3'

end
