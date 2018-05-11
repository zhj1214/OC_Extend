

Pod::Spec.new do |s|
  s.name             = 'OC_Extend'
  s.version          = '0.1.0'
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
  
  # s.framework  = "UIkit"
  s.frameworks = "UIkit","Security", "CFNetwork",'Foundation','QuartzCore','MapKit','MobileCoreServices', 'CoreGraphics'
  s.libraries = 'iconv'

  s.dependency "AFNetworking", "~> 3.2.1"
  s.dependency "SAMKeychain", "~> 1.5.3"
  # s.dependency "MyOftenUseTool"

  s.requires_arc = true
  # s.resource_bundles = {
  #   'Extend' => ['Extend/Assets/*.png']
  # }

  # => 创建个人目录  
  s.source_files = 'OC_Extend/Classes/OC_ExtendHeader.h'
  s.public_header_files = 'OC_Extend/Classes/OC_ExtendHeader.h'

  s.subspec 'IPTool' do |ss|
    ss.source_files = 'OC_Extend/Classes/IPTool/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/IPTool/*.h'
  end

  s.subspec 'APPSeting' do |ss|
    # ss.ios.deployment_target = '8.0'
    ss.dependency 'OC_Extend/IPTool'
    ss.ios.dependency 'OC_Extend/IPTool'

    ss.source_files = 'OC_Extend/Classes/APPSeting/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/APPSeting/*.h'
  end

  

  s.subspec 'CheckText' do |ss|
    ss.dependency 'OC_Extend/APPSeting'
    ss.ios.dependency 'OC_Extend/APPSeting'
    # ,'OC_Extend/Classes/APPSeting/AppEnum.h'
    # ,'OC_Extend/Classes/APPSeting/AppEnum.h'
    ss.source_files = 'OC_Extend/Classes/CheckText/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/CheckText/*.h'
  end

  s.subspec 'NetworkManager' do |ss|
    ss.dependency 'OC_Extend/APPSeting'
    ss.ios.dependency 'OC_Extend/APPSeting'

    ss.source_files = 'OC_Extend/Classes/NetworkManager/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/NetworkManager/*.h'
  end

  s.subspec 'CommonSecretData' do |ss|
    ss.source_files = 'OC_Extend/Classes/CommonSecretData/**/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/CommonSecretData/**/*.h'
  end

  s.subspec 'UIExtension' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.source_files = 'OC_Extend/Classes/UIExtension/**/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/UIExtension/**/*.h'
  end

  s.subspec 'APPLocation' do |ss|
    ss.dependency 'OC_Extend/UIExtension'
    ss.ios.dependency 'OC_Extend/UIExtension'

# ,'OC_Extend/Classes/UIExtension/UIViewController/UIViewController+Utils.{h,m}'
# ,'OC_Extend/Classes/UIExtension/UIViewController/UIViewController+Utils.h'
    ss.source_files = 'OC_Extend/Classes/APPLocation/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/APPLocation/*.h'
    # ss.watchos.frameworks = 'MobileCoreServices', 'CoreGraphics'
    # ss.ios.frameworks = 'MobileCoreServices', 'CoreGraphics'
    # ss.osx.frameworks = 'CoreServices'
  end

  s.subspec 'NSExtension' do |ss|
    ss.source_files = 'OC_Extend/Classes/NSExtension/**/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/NSExtension/**/*.h'
  end

  s.subspec 'MBProgressHUD' do |ss|
    ss.source_files = 'OC_Extend/Classes/MBProgressHUD/*.{h,m}'
    ss.public_header_files = 'OC_Extend/Classes/MBProgressHUD/*.h'
  end
end
