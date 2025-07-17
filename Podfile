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
        
        # Framework header 오류 해결 (nanopb, leveldb 등)
        config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
        
        # gRPC 관련 오류 해결
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=0'
        
        # nanopb 및 leveldb 관련 오류 해결
        config.build_settings['HEADER_SEARCH_PATHS'] ||= ['$(inherited)']
        config.build_settings['HEADER_SEARCH_PATHS'] << '$(PODS_TARGET_SRCROOT)'
        config.build_settings['HEADER_SEARCH_PATHS'] << '$(PODS_ROOT)/leveldb-library/include'
        
        # 추가 컴파일러 설정 - framework header 문제 완전 해결
        config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
        config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      end
    end
  end

  # Pods.xcodeproj - 특정 라이브러리별 수정
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      flags = config.build_settings['OTHER_CFLAGS']
      if flags.is_a?(String)
        config.build_settings['OTHER_CFLAGS'] = flags.gsub('-G', '')
      elsif flags.is_a?(Array)
        config.build_settings['OTHER_CFLAGS'] = flags.map { |f| f.gsub('-G', '') }
      end
      
      # 모든 pods에 framework header 경고 비활성화 적용
      config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      config.build_settings['GCC_TREAT_WARNINGS_AS_ERRORS'] = 'NO'
      
      # LevelDB 관련 특별 설정
      if target.name.include?("leveldb")
        config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
        config.build_settings['WARNING_CFLAGS'] = ['$(inherited)', '-Wno-quoted-include-in-framework-header']
      end
    end
  end

  # Pods.xcodeproj - abseil 패치 (기존 코드 유지)
  abseil_umbrella = File.join(__dir__, 'Pods', 'Target Support Files', 'abseil', 'abseil-umbrella.h')
  if File.exist?(abseil_umbrella)
    text = File.read(abseil_umbrella)
    text = text.gsub(/#include\s+"algorithm\/(.+)"/, '#include <absl/algorithm/\1>')
    File.write(abseil_umbrella, text)
  end
end
