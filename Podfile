platform :ios, '15.0'

target 'Ballog' do
  use_frameworks!

  pod 'Firebase/Core'
  pod 'Firebase/Firestore', '~> 10.15.0'
  pod 'FirebaseFirestoreSwift', '~> 10.15.0'
end


post_install do |installer|
  # Ballog.xcodeproj
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        # 필수: iOS 12.0 이상 강제
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end

  # Pods.xcodeproj - abseil 패치
  abseil_umbrella = File.join(__dir__, 'Pods', 'Target Support Files', 'abseil', 'abseil-umbrella.h')
  if File.exist?(abseil_umbrella)
    text = File.read(abseil_umbrella)
    text = text.gsub(/#include\s+"algorithm\/(.+)"/, '#include <absl/algorithm/\1>')
    File.write(abseil_umbrella, text)
  end

  # Pods.xcodeproj - OTHER_CFLAGS -G 제거
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      flags = config.build_settings['OTHER_CFLAGS']
      if flags.is_a?(String)
        config.build_settings['OTHER_CFLAGS'] = flags.gsub('-G', '')
      elsif flags.is_a?(Array)
        config.build_settings['OTHER_CFLAGS'] = flags.map { |f| f.gsub('-G', '') }
      end
    end
  end
end
