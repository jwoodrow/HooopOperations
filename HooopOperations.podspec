Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '9.0'
s.swift_version = '5.0'
s.name = "HooopOperations"
s.summary = "Hooop Operations used to have a coherence with the back end"
s.requires_arc = true

s.version = "0.1.1"

s.license = { :type => 'All rights reserved.', :text => <<-LICENSE
Copyright (C) HOOOP, Inc - All Rights Reserved
Unauthorized copying of this file, via any medium is strictly prohibited
Proprietary and confidential
Written by James Woodrow <james@hooop.fr>, March 2018
LICENSE
}

s.author = { "James Woodrow" => "james@hooop.fr" }

s.homepage = "https://github.com/jwoodrow/HooopOperations"

s.source = { :git => "https://github.com/jwoodrow/HooopOperations.git", :tag => "#{s.version}"}

s.framework = "UIKit"
s.dependency "Alamofire", "4.8.2"
s.dependency "HooopModels", "0.1.3"

s.source_files = "HooopOperations/**/*.{swift}"

end
