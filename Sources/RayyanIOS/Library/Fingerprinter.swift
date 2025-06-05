/// Main `FingerprintJS` class that provides an interface to all library functions (device identifier and fingerprint retrieval)
public class Fingerprinter {
    private let configuration: Configuration
    private let identifiers: IdentifierHarvesting
    private let treeProvider: DeviceInfoTreeProvider
    private let fingerprintCalculator: FingerprintTreeCalculator

    convenience init(_ configuration: Configuration) {
        self.init(
            configuration,
            identifiers: IdentifierHarvester(),
            deviceInfoTree: CompoundTreeBuilder(),
            fingerprintCalculator: FingerprintTreeCalculator()
        )
    }

    init(
        _ configuration: Configuration,
        identifiers: IdentifierHarvesting,
        deviceInfoTree: DeviceInfoTreeProvider,
        fingerprintCalculator: FingerprintTreeCalculator
    ) {
        self.configuration = configuration
        self.identifiers = identifiers
        self.treeProvider = deviceInfoTree
        self.fingerprintCalculator = fingerprintCalculator
    }

}

// MARK: - Public Interface
extension Fingerprinter {
    /// Retrieves a stable device identifier that is tied to the current device/application combination
    /// - Parameter completion: Block called with the device identifier `String` value or `nil` if an error occurs
    /// - SeeAlso: [Device Identifier and Fingerprint Stability](https://github.com/fingerprintjs/fingerprintjs-ios#device_identifier_and_fingerprint_stability)
    public func getDeviceId(_ completion: @escaping (String?) -> Void) {
        completion(self.identifiers.vendorIdentifier?.uuidString)
    }

    /// Computes device fingerprint from a combination of hardware information and device identifiers.
    ///
    /// The fingerprint is computed with a hash function previously specified through the `Configuration`
    /// object that was passed through the initializer
    ///  - Parameter completion: Block called with a `String` representing the fingerprint or `nil` if any error occured
    public func getFingerprint(_ completion: @escaping (String?) -> Void) {
        getFingerprintTree { deviceItem in
            completion(deviceItem.fingerprint)
        }
    }

    /// Gets fingerprint information in its raw form (includes both the data and the fingerprint itself) as a tree of
    /// fingerprinted `DeviceItemInfo` items.
    ///
    /// - Parameter completion: Block called with `FingerprintTree` object that encapsulates both
    /// the hardware information as well as the final computed fingerprint.
    public func getFingerprintTree(_ completion: @escaping (FingerprintTree) -> Void) {
        let inputTree = treeProvider.buildTree(configuration)
        let fingerprintTree = fingerprintCalculator.calculateFingerprints(
            from: inputTree,
            hashFunction: configuration.hashFunction
        )
        completion(fingerprintTree)
    }

    /// Retrieves all fingerprint signals grouped by category as a [String: [String: String]] dictionary.
    public func getAllFingerprintSignalsByCategory() -> [String: [String: String]] {
        let inputTree = treeProvider.buildTree(configuration)
        var result: [String: [String: String]] = [:]

        func collectSignals(from item: DeviceInfoItem) -> [String: String] {
            var signals: [String: String] = [:]
            switch item.value {
            case .info(let value):
                signals[item.label] = value
            case .category:
                item.children?.forEach { child in
                    switch child.value {
                    case .category:
                        // Nested category, skip for now (handled at top level)
                        break
                    case .info(let value):
                        signals[child.label] = value
                    }
                }
            }
            return signals
        }

        // Top-level categories: App, Hardware, Operating System, Identifiers, Cellular Network, Local Authentication
        inputTree.children?.forEach { category in
            let key = category.label.camelCasedKey()
            let signals = collectSignals(from: category)
            if !signals.isEmpty {
                result[key] = signals
            }
        }
        return result
    }

    /// Retrieves all fingerprint signals grouped by category as a JSON string.
    public func getAllFingerprintSignalsByCategoryJSON() -> String? {
        let signalsByCategory = getAllFingerprintSignalsByCategory()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: signalsByCategory, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

// MARK: - Public Interface: Async/Await (iOS 13+)
@available(iOS 13.0, tvOS 13.0, *)
extension Fingerprinter {
    /// Retrieves a stable device identifier that is tied to the current device/application combination
    /// - Returns: Device identifier `String` value or `nil` if an error occurs
    /// - SeeAlso: [Device Identifier and Fingerprint Stability](https://github.com/fingerprintjs/fingerprintjs-ios#device_identifier_and_fingerprint_stability)
    public func getDeviceId() async -> String? {
        return await withCheckedContinuation({ continuation in
            self.getDeviceId { deviceId in
                continuation.resume(with: .success(deviceId))
            }
        })
    }

    /// Gets fingerprint information in its raw form (includes both the data and the fingerprint itself) as a tree of
    /// fingerprinted `DeviceItemInfo` items.
    ///
    /// - Returns: `FingerprintTree` object that encapsulates both the hardware information as well as the final computed fingerprint.
    public func getFingerprintTree() async -> FingerprintTree {
        return await withCheckedContinuation({ continuation in
            self.getFingerprintTree({ tree in
                continuation.resume(with: .success(tree))
            })
        })
    }

    /// Computes device fingerprint from a combination of hardware information and device identifiers.
    ///
    /// The fingerprint is computed with a hash function previously specified through the `Configuration`
    /// object that was passed through the initializer
    ///  - Returns: `String` representing the fingerprint or `nil` if any error occured
    public func getFingerprint() async -> String? {
        return await withCheckedContinuation({ continuation in
            self.getFingerprint { fingerprint in
                continuation.resume(with: .success(fingerprint))
            }
        })
    }
}

// Helper to convert category label to camelCase key
private extension String {
    func camelCasedKey() -> String {
        let components = self.components(separatedBy: " ")
        guard let first = components.first?.lowercased() else { return self }
        let rest = components.dropFirst().map { $0.capitalized }
        return ([first] + rest).joined()
    }
}
