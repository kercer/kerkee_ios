Pod::Spec.new do |s|
  s.name         = "kerkee"
  s.version      = "1.0.1"
  s.summary      = "kerkee is a hybrid app framework,This repository is kerkee for ios"
  s.description  = "kerkee is a hybrid app framework,This repository is kerkee for ios, is the multi-agent framework"

  s.homepage     = "http://www.kerkee.com"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "GNU"
  # s.license      = { :type => "MIT", :file => "LICENSE" }
  
  # Or just: s.author    = "kercer"
  # s.authors            = { "kercer" => "email@address.com" }
  # s.social_media_url   = "http://twitter.com/kercer"
  s.author             = { "zihong" => "zihong87@gmail.com" }
  s.social_media_url   = "http://www.kerkee.com"
  
  # s.platform     = :ios
  s.platform     = :ios, "7.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  
  s.source       = { :git => "https://github.com/kercer/kerkee_ios.git", :tag => "v1.0.1" }
  #s.source       = { :git => "/Users/zihong/Desktop/workspace/kercer/kerkee_ios", :tag => "v1.0.1" }
  
  s.source_files  = "kerkee_ios", "kerkee/**/*.{h,m}"
  s.exclude_files = "kerkee/kerkeeTests", "kerkee/dependencies"

  # s.public_header_files = "Classes/**/*.h"


  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = 'Foundation', 'CoreGraphics', 'UIKit'
  # s.frameworks = "SomeFramework", "AnotherFramework"

  s.library   = "z"
  # s.libraries = "iconv", "xml2"


  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"
  s.dependency 'SSKeychain'
  # s.dependency 'Reachability'



end
