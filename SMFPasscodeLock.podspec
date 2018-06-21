#
# Be sure to run `pod lib lint TestLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name = 'SMFPasscodeLock'
	s.version = '2.0.1'
	s.license = { :type => "MIT", :file => 'LICENSE.txt' }
	s.summary = 'SMF Fork of PasscodeLock: An iOS passcode lock with Touch ID authentication written in Swift.'
	s.homepage = 'https://github.com/smartmobilefactory/SwiftPasscodeLock'
	s.source = { :git => 'https://github.com/smartmobilefactory/SwiftPasscodeLock.git', :tag => "versions/#{s.version}" }
	s.authors = [{ 'Ramiro Ramirez' => '' }, { 'Yanko Dimitrov' => '' }, { 'Hans Seiffert' => '' }]

	s.ios.deployment_target = '8.0'

	s.source_files = 'PasscodeLock/*.{h,swift}',
					 'PasscodeLock/*/*.{swift}'

	s.resources = [
				'PasscodeLock/Views/PasscodeLockView.xib',
				'PasscodeLock/en.lproj/*',
				'PasscodeLock/PasscodeLockImages.xcassets',
				'PasscodeLock/PasscodeLockImages.xcassets/**/*'
			  ]

	s.requires_arc = true
end
