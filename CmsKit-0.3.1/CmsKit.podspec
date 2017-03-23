Pod::Spec.new do |s|
  s.name = "CmsKit"
  s.version = "0.3.1"
  s.summary = "cms sdk for iOS"
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"ycs"=>"1214099793@qq.com"}
  s.homepage = "https://github.com/YcsGH/CmsKit"
  s.description = "cms sdk for ios"
  s.frameworks = ["SystemConfiguration", "MobileCoreServices", "CoreGraphics"]
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/CmsKit.framework'
end
