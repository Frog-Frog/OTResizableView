Pod::Spec.new do |s|

  s.name         = "OTResizableView"
  s.version      = "1.0"
  s.summary      = "OTResizableView is a UIView library that can be resized with fingers."
  s.homepage     = "https://github.com/PKPK-Carnage/OTResizableView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Tomosuke Okada" => "pkpkcarnage@gmail.com" }
  s.social_media_url   = "https://github.com/PKPK-Carnage"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/PKPK-Carnage/OTResizableView.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "Classes/*.{swift}"
  s.requires_arc = true

end
