Pod::Spec.new do |s|
  s.name             = 'GMStoryVideoPlayer'
  s.version          = '0.1.0'
  s.summary          = 'iOS Obj-C Story Video Player like Instagram and Snapchat with back, forth, loop and video caching'

  s.description      = <<-DESC
	iOS Video Player based on raw AVPlayer with an algorithm to create a Instagram/Snapchar Story player like. 
	It supports
		* Fast/Instant tap and skip to next/prev video
		* Preloading
		* Thumnails
		* Video Caching
                       DESC

  s.homepage         = 'https://github.com/gaston23/GMStoryVideoPlayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gaston Morixe' => 'gaston@black.uy' }
  s.source           = { :git => 'https://github.com/gaston23/GMStoryVideoPlayer.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/gastoon___'

  s.ios.deployment_target = '10.0'

  s.source_files = 'GMStoryVideoPlayer/Classes/**/*', 'libs/VIMediaCache/VIMediaCache/*.{h,m}', 'libs/VIMediaCache/VIMediaCache/**/*.{h,m}'
  s.frameworks = 'MobileCoreServices', 'AVFoundation'

  s.dependency 'SpinKit'
  s.dependency 'SDWebImage'
end
