import Foundation

@testable import RayyanIOS

class MockFingerprintFunction: FingerprintFunction {
    var fakeHash: String = ""

    func fingerprint(data: Data) -> String {
        return fakeHash
    }
}
