require 'json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name = 'DadstrongBridge'
  s.version = package['version']
  s.summary = package['description']
  s.license = package['license']
  s.homepage = 'https://github.com/Spiermen/overload-tracker'
  s.author = package['author']
  s.source = { :git => 'https://github.com/Spiermen/overload-tracker.git', :tag => s.version.to_s }
  s.source_files = 'ios/Sources/DadStrongBridgePlugin/**/*.{swift,h,m,c,cc,mm,cpp}'
  s.ios.deployment_target = '15.0'
  s.dependency 'Capacitor'
  s.swift_version = '5.1'
  s.frameworks = 'HealthKit', 'WidgetKit'
end
