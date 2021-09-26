#
#  Be sure to run `pod spec lint AppsFlyerResolver.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "AppsFlyerURLResolver"
  spec.version      = "0.0.1"
  spec.summary      = "AppsFLyer URL Resolver"
  spec.description  = <<-DESC
  AppsFlyer is the market leader in mobile advertising attribution & analytics, helping marketers to pinpoint their targeting, optimize their ad spend and boost their ROI.
                   DESC

  spec.homepage     = "https://github.com/AppsFlyerSDK/AppsFlyerURLResolver"
  spec.license      = "MIT"
  spec.author       = { "pazlavi" => "paz.lavi@appsflyer.com" }
  spec.source       = { :git => "https://github.com/AppsFlyerSDK/AppsFlyerURLResolver.git", :tag => spec.version.to_s }
  spec.source_files = 'iOS/AppsFlyerURLResolver/Sources//**/*.{swift,h,m}'

end