#
# Be sure to run `pod lib lint SamUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SamUtils'
  s.version          = '0.0.3'
  s.summary          = 'The common tools with Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This sdk is the common tools with Swift.
  It also include dependency commonly used tools.
                       DESC

  s.homepage         = 'https://github.com/Dusam/SamUtils'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dusam' => 'sam6124883@gmail.com' }
  s.source           = { :git => 'https://github.com/Dusam/SamUtils.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/Dusam'

  s.ios.deployment_target = '11.0'
  s.swift_version = "5.7"

  s.default_subspec = 'CommonTools'

  # Default
  s.subspec 'CommonTools' do |sp|
    sp.source_files  = 'SamUtils/*.swift'
    sp.exclude_files = 'SamUtils/Bluetooth/*.swift'

    sp.subspec 'API' do |spp|
      spp.source_files = 'SamUtils/API/*.swift'
    end

    sp.subspec 'Extensions' do |spp|
      spp.source_files = 'SamUtils/Extensions/*.swift'
    end

  end

  # Introduce when needed
  s.subspec 'Bluetooth' do |sp|
    sp.source_files  = 'SamUtils/Bluetooth/*.swift'
  end

  s.dependency 'Alamofire'
  s.dependency 'SwifterSwift'
  s.dependency 'IQKeyboardManagerSwift'
  
  # s.resource_bundles = {
  #   'SamUtils' => ['SamUtils/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
