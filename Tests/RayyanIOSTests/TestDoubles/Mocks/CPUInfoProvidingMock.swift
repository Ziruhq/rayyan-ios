@testable import RayyanIOS

class CPUInfoProvidingMock: CPUInfoProviding {
    var processorCountCalled = true
    var mockProcessorCount = 0

    var processorCount: Int {
        processorCountCalled = true
        return mockProcessorCount
    }
}
