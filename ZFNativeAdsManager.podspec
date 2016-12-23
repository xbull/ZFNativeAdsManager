Pod::Spec.new do |s|

  s.name         = 'ZFNativeAdsManager'
  s.version      = '1.1.0'
  s.summary      = 'ZFNativeAdsManager integrates and dispatches mainstream leading native ads platform.'
  s.homepage     = 'https://github.com/xbull/ZFNativeAdsManager'
  s.license      = 'MIT'
  s.author             = { 'ruozi' => 'wizardfan88@gmail.com' }
  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/xbull/ZFNativeAdsManager.git', :tag => s.version}

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|

    ss.source_files = 'ZFNativeAdsManager/*.{h,m}', 'ZFNativeAdsManager/Mediator/*.{h,m}', 'ZFNativeAdsManager/Categories/*.{h,m}'
    ss.public_header_files = 'ZFNativeAdsManager/*.h'
    ss.requires_arc = 'ZFNativeAdsManager/*.m'

  end

  s.subspec 'Facebook' do |ss|

    ss.dependency 'ZFNativeAdsManager/Core'
    ss.dependency 'FBAudienceNetwork', '~> 4.18.0'
    ss.source_files = 'ZFNativeAdsManager/Platforms/Facebook/*.{h,m}', 'ZFNativeAdsManager/Platforms/Facebook/Action/*.{h,m}'

  end   

  s.subspec 'Mobvista' do |ss|

    ss.dependency 'ZFNativeAdsManager/Core'
    ss.source_files = 'ZFNativeAdsManager/Platforms/Mobvista/*.{h,m}', 'ZFNativeAdsManager/Platforms/Mobvista/Action/*.{h,m}', 'ZFNativeAdsManager/Platforms/Mobvista/Observer/*.{h,m}'
    ss.frameworks = 'CoreGraphics', 'Foundation', 'UIKit', 'AdSupport', 'StoreKit', 'QuartzCore', 'CoreLocation', 'CoreTelephony', 'MobileCoreServices', 'Accelerate', 'SystemConfiguration', 'CoreMotion', 'AVFoundation', 'CoreMedia', 'MessageUI', 'MediaPlayer'
    ss.vendored_frameworks = 'ZFNativeAdsManager/Platforms/Mobvista/Frameworks/MVSDK.framework'
    ss.libraries = 'z', 'sqlite3'

  end   

  s.subspec 'MVAppWall' do |ss|

    ss.dependency 'ZFNativeAdsManager/Core'
    ss.dependency 'ZFNativeAdsManager/Mobvista'
    ss.source_files = 'ZFNativeAdsManager/Platforms/MVAppWall/*.{h,m}', 'ZFNativeAdsManager/Platforms/MVAppWall/Action/*.{h,m}'
    ss.frameworks = 'CoreGraphics', 'Foundation', 'UIKit', 'AdSupport', 'StoreKit', 'QuartzCore', 'CoreLocation', 'CoreTelephony', 'MobileCoreServices', 'Accelerate', 'SystemConfiguration', 'CoreMotion', 'AVFoundation', 'CoreMedia', 'MessageUI', 'MediaPlayer'
    ss.vendored_frameworks = 'ZFNativeAdsManager/Platforms/MVAppWall/Frameworks/MVSDKAppWall.framework'
    ss.libraries = 'z', 'sqlite3'

  end   

end
