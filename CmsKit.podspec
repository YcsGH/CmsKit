#
# Be sure to run `pod lib lint CmsKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CmsKit'
  s.version          = '1.0.5'
  s.summary          = 'cms sdk for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'cms sdk for ios'

  s.homepage         = 'https://github.com/YcsGH/CmsKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'missL' => '1214099793@qq.com' }
  s.source           = { :git => 'https://github.com/YcsGH/CmsKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CmsKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CmsKit' => ['CmsKit/Assets/*.png']
  # }

  s.public_header_files = 'CmsKit/Classes/Public/*.h'
  s.frameworks = 'SystemConfiguration','MobileCoreServices','CoreGraphics'
  s.dependency 'AFNetworking', '~> 3.1.0'
end
