Pod::Spec.new do |spec|

    spec.name         = "xcode-tool"
    spec.version      = "1.0.0"
    spec.license      = "MIT"
    spec.summary      = "A collection of useful tools for an xcode project"
    spec.description  = "xct is a collection of useful gadgets for an xcode project"
    spec.homepage     = "https://github.com/TBXark/xcode-tool"
    s.author       = { "TBXark" => "tbxark@outlook.com" }
    spec.requires_arc       = true
    spec.source             = { :http => "https://github.com/TBXark/xcode-tool/releases/download/v#{spec.version}/rswift-v#{spec.version}.zip" }
    spec.swift_version      = "5.1"
  
    spec.ios.deployment_target     = '9.0'
    spec.tvos.deployment_target    = '9.0'
    spec.watchos.deployment_target = '2.2'
  
    spec.dependency "R.swift.Library", "~> 5.3.0"
    spec.preserve_paths = "xct"
  
  end