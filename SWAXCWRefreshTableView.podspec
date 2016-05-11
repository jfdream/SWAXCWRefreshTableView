#
# Be sure to run `pod lib lint SWAXCWRefreshTableView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SWAXCWRefreshTableView"
  s.version          = "2.1"
  s.summary          = "修复CWRefreshTableView中的某些代理问题"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "在原有CWRefreshTableView中添加某些UIScrollView的代理方法"

  s.homepage         = "https://github.com/jfdream/SWAXCWRefreshTableView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "jfdreamyang" => "jfdream1992@126.com" }
  s.source           = { :git => "https://github.com/jfdream/SWAXCWRefreshTableView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'SWAXCWRefreshTableView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SWAXCWRefreshTableView' => ['SWAXCWRefreshTableView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
