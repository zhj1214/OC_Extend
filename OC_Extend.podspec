

Pod::Spec.new do |s|
  s.name             = 'OC_Extend'
  s.version          = '0.0.1'
  s.summary          = '在这里你将看到 iOS Objective-C 的组件扩展'

  s.description      = <<-DESC
            不积跬步无以至千里；每天增加一个组建的扩展功能，督促自己每天都要进步。
                       DESC

  s.homepage         = 'https://github.com/zhj1214/OC_Extend'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hongjun.zhang' => 'zhj1214@hotmail.com' }
  s.source           = { :git => 'https://github.com/zhj1214/OC_Extend.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  
  s.framework  = "UIkit"
  s.frameworks = "Security", "CFNetwork"

  # s.resource_bundles = {
  #   'Extend' => ['Extend/Assets/*.png']
  # }

  # 导入文件夹
  # 'PublicClass/AppEnum.h'
  s.public_header_files = 'OC_Extend/Classes/OC_ExtendHeader.h'
  s.source_files = 'OC_Extend/Classes/*.{h,m}'
  

  s.subspec 'APPLocation' do |ss|
    ss.source_files = 'OC_Extend/Classes/APPLocation/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/APPLocation/*.h'
    # ss.watchos.frameworks = 'MobileCoreServices', 'CoreGraphics'
    # ss.ios.frameworks = 'MobileCoreServices', 'CoreGraphics'
    # ss.osx.frameworks = 'CoreServices'
  end

  s.subspec 'CheckText' do |ss|
    ss.source_files = 'OC_Extend/Classes/CheckText/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/CheckText/*.h'
  end

  s.subspec 'CommonSecretData' do |ss|
    ss.source_files = 'OC_Extend/Classes/CommonSecretData/**/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/CommonSecretData/**/*.h'
  end

  s.subspec 'NSExtension' do |ss|
    ss.source_files = 'OC_Extend/Classes/NSExtension/**/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/NSExtension/**/*.h'
  end

  s.subspec 'UIExtension' do |ss|
    ss.source_files = 'OC_Extend/Classes/UIExtension/**/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/UIExtension/**/*.h'
  end

  s.subspec 'MBProgressHUD' do |ss|
    ss.source_files = 'OC_Extend/Classes/MBProgressHUD/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/MBProgressHUD/*.h'
  end

  s.subspec 'SAMKeychain' do |ss|
    ss.source_files = 'OC_Extend/Classes/SAMKeychain/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/SAMKeychain/*.h'
  end

  s.dependency "AFNetworking", "~> 3.2"
end
