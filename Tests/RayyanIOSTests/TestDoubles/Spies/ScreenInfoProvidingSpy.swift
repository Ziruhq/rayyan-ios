import Foundation

@testable import RayyanIOS

final class ScreenInfoProvidingSpy: ScreenInfoProviding {

    var nativeBoundsReturnValue: CGRect = .zero
    var nativeScaleReturnValue: CGFloat = .zero

    private(set) var nativeBoundsCallCount: Int = .zero
    private(set) var nativeScaleCallCount: Int = .zero

    var nativeBounds: CGRect {
        nativeBoundsCallCount += 1
        return nativeBoundsReturnValue
    }

    var nativeScale: CGFloat {
        nativeScaleCallCount += 1
        return nativeScaleReturnValue
    }
}
