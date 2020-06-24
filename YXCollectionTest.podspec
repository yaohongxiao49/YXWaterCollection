Pod::Spec.new do |spec|

  spec.name         = "YXCollectionTest"
  spec.version      = "0.0.1"
  spec.summary      = "悬停瀑布流"

  spec.description  = <<-DESC
                        可悬停瀑布流
                   DESC

  spec.homepage     = "https://github.com/yaohongxiao49/YXWaterCollectionDemo"
 
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "yaohongxiao" => "617146817@qq.com" }

  spec.platform     = :ios
  
  spec.source       = { :git => "https://github.com/yaohongxiao49/YXWaterCollectionDemo.git", :tag => "#{spec.version}" }

  spec.source_files  = "Classes", "YXCollectionTest/**/*.{h,m}"
  spec.exclude_files = "Classes/Exclude"
 #spec.framework  = "SystemConfiguration"
  spec.requires_arc  = true

end
