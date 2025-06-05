Pod::Spec.new do |spec|
  # Name and version
  spec.name         = 'RayyanIOS'
  spec.version      = '1.6.0'

  # License
  spec.license      = { type: 'MIT', file: 'LICENSE' }

  # Contact information
  spec.homepage     = 'https://rayyan.com/'
  spec.authors      = {
    'Fingerprint': 'ios@rayyancom',
    'victor Enoma': 'victor@ziru.ventures',
    'Petr Palata': 'petr.palata@fingerprint.com'
  }

  # RayyanIOS description
  spec.summary = 'Lightweight device fingerprinting library for iOS'
  spec.description = <<-DESC
  RayyanIOS provides a simple API to generate a unique device fingerprint computed from a combination
  of device signals (hardware information, available identifiers, OS information and device settings).
  It operates only locally (i.e. no data are sent, seen or stored by a third party).
  DESC

  # Git location
  spec.source = {
    git: 'https://github.com/Ziruhq/rayyan-ios.git', tag: spec.version
  }

  # Build (deployment target, Swift versions)
  spec.ios.deployment_target = '12.0'
  spec.tvos.deployment_target = '12.0'
  spec.swift_versions = ['5.7', '5.8', '5.9']
  spec.default_subspec = 'Core'

  # Core
  spec.subspec 'Core' do |core|
    core.source_files = 'Sources/RayyanIOS/**/*.{swift,h,m}'
    core.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Tests/RayyanIOSTests/**/*.{swift,h,m}'
    end

    core.dependency 'RayyanIOS/SystemControl'
  end

  # SystemControl
  spec.subspec 'SystemControl' do |sysctl|
    sysctl.source_files = 'Sources/SystemControl/**/*.{swift,h,m}'
    sysctl.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Tests/SystemControlTests/**/*.{swift,h,m}'
    end
  end
end
