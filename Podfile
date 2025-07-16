
# Uncomment the next line to define a global platform for your project
project 'Ballog.xcodeproj'
platform :ios, '15.0'

target 'Ballog' do
  use_frameworks!
  pod 'Firebase/Firestore'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 12.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
      end
    end
  end

  # abseil-umbrella.h 자동 패치
  abseil_umbrella = File.join(__dir__, 'Pods', 'Target Support Files', 'abseil', 'abseil-umbrella.h')
  if File.exist?(abseil_umbrella)
    text = File.read(abseil_umbrella)
    # "algorithm/algorithm.h" → <absl/algorithm/algorithm.h>
    text = text.gsub(/#include\s+"algorithm\/(.+)"/, '#include <absl/algorithm/\1>')
    File.write(abseil_umbrella, text)
  end
end

