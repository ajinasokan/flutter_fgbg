#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_fgbg.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_fgbg'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin to detect when app(not Flutter container) goes to background or foreground'
  s.description      = <<-DESC
Flutter plugin to detect when app(not Flutter container) goes to background or foreground
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_fgbg/Sources/flutter_fgbg/**/*.swift'
  s.resource_bundles = {'flutter_fgbg_privacy' => ['flutter_fgbg/Sources/flutter_fgbg/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
