Pod::Spec.new do |s|
  s.name         = "kerkee"
  s.version      = "1.0.5"
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
  s.platform     = :ios, "8.0"

  #  When using multiple platforms
  # s.ios.deployment_target = "5.0"
  # s.osx.deployment_target = "10.7"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"
  
  #s.source       = { :git => "/Users/zihong/Desktop/workspace/kercer/kerkee_ios", :tag => "v1.0.1" }
  s.source       = { :git => "https://github.com/kercer/kerkee_ios.git", :tag => "#{s.version}", :submodules => true  }
  
  s.source_files  = "kerkee/**/*.{h,m}"

  s.public_header_files = "kerkee/**/*.h"


  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  s.framework  = 'Foundation', 'CoreGraphics', 'UIKit'
  
  # s.frameworks = "SomeFramework", "AnotherFramework"

  s.library   = "z"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true
  # non_arc_files = 'kerkee/Browser/WebView/KCUtilWebView.{h,m}'
  # s.exclude_files = non_arc_files
  # s.subspec 'no-arc' do |ss|
    # ss.requires_arc = false
    # ss.frameworks = "UIKit", "Foundation" #支持的框架
    # ss.source_files = non_arc_files
  # end
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency 'SSKeychain','~>1.2.3'
  # s.dependency 'Reachability'



end
