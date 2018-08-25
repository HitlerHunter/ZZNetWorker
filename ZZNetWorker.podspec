Pod::Spec.new do |s|
s.name             = 'ZZNetWorker'
s.version          = '0.1.0'
s.summary          = 'ZZNetWorker. zlz'

s.description      = <<-DESC
a networkTool base AFNetworking
DESC

s.homepage         = 'https://github.com/HitlerHunter/ZZNetWorker'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'HitlerHunter' => '15581580575@163.com' }
s.source           = { :git => 'https://github.com/HitlerHunter/ZZNetWorker.git', :tag => s.version.to_s }


s.ios.deployment_target = '8.0'
s.source_files = 'Classes'
s.dependency 'AFNetworking', '~> 3.2.1'
end
