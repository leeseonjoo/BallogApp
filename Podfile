platform :ios, '15.0'

target 'Ballog' do
  use_frameworks!

  pod 'Firebase/Core', '~> 10.12.0'
  pod 'Firebase/Firestore', '~> 10.12.0'
  pod 'FirebaseFirestoreSwift', '~> 10.12.0'
end

post_install do |installer|
  # Ballog.xcodeproj
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        # 필수: iOS 12.0 이상 강제
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        
        # Framework header 오류 해결
        config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
        
        # gRPC 관련 오류 해결
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=0'
        
        # nanopb 관련 오류 해결
        config.build_settings['HEADER_SEARCH_PATHS'] ||= ['$(inherited)']
        config.build_settings['HEADER_SEARCH_PATHS'] << '$(PODS_TARGET_SRCROOT)'
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
      
      # nanopb 및 gRPC 관련 추가 설정
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
    end
  end
end
