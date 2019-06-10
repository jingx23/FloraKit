Pod::Spec.new do |s|
  s.name                      = "FloraKit"
  s.version                   = "1.0.0"
  s.summary                   = "FloraKit"
  s.homepage                  = "https://github.com/jingx23/FloraKit"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Jan Scheithauer" => "me@jingx.net" }
  s.source                    = { :git => "https://github.com/jingx23/FloraKit.git", :tag => s.version.to_s }
  s.ios.deployment_target     = "8.0"
  s.tvos.deployment_target    = "9.0"
  s.watchos.deployment_target = "2.0"
  s.osx.deployment_target     = "10.10"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"
end
