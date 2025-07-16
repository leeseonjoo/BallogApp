
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
end

