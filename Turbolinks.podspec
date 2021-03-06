Pod::Spec.new do |s|
  s.name         = "Turbolinks"
  s.version      = "3.0.0"
  s.summary      = "Turbolinks for iOS"
  s.homepage     = "http://github.com/wftllc/turbolinks-ios"
  s.license      = "MIT"
  s.authors      = { "Sam Stephenson" => "sam@basecamp.com", "Jeffrey Hardy" => "jeff@basecamp.com", "Zach Waugh" => "zach@basecamp.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "git@github.com:wftllc/turbolinks-ios.git" }
  s.source = {:path => "." }
  s.source_files  = "Turbolinks/*.swift"
  s.resources = "Turbolinks/*.js"
  s.framework  = "WebKit"
  s.requires_arc = true
end
