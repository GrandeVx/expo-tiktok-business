require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "expo-tiktok-business"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.author       = package["author"]
  s.source       = { :git => package["repository"]["url"], :tag => s.version.to_s }

  s.platforms    = { :ios => "13.0" }
  s.swift_version = "5.0"

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.dependency "React-Core"
  s.dependency "TikTokBusinessSDK", "~> 1.3"

  install_modules_dependencies(s)
end
