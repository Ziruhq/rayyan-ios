import Foundation

@testable import RayyanIOS

final class VendorIdentifierProvidingSpy: VendorIdentifierProviding {
    private(set) var vendorIdentifierCallCount: Int = .zero

    var vendorIdentifierReturnValue: UUID? = nil

    var identifierForVendor: UUID? {
        vendorIdentifierCallCount += 1
        return vendorIdentifierReturnValue
    }
}
