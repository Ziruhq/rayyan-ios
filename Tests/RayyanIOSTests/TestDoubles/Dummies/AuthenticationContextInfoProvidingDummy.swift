@testable import RayyanIOS

@available(tvOS, unavailable)
struct AuthenticationContextInfoProvidingDummy: AuthenticationContextInfoProviding {
    let isPasscodeEnabled: Bool = false
    let isBiometricsEnabled: Bool = false
    let supportedBiometryType: BiometryType = .unknown
}
