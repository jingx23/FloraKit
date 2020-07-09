//
//  FloraKit.swift
//  FloraKit
//
//  Created by Jan Scheithauer on 10 Jun 2019.
//  Copyright © 2019 Jan Scheithauer. All rights reserved.
//

// Include Foundation
@_exported import Foundation

///
/// FloraKit Delegate
public protocol FloraKitDelegate: class {
    ///
    /// Reports state changes from flora devices
    /// - Parameters:
    ///   - floraKit: FloraKit object.
    ///   - state: `FloraService.FloraServiceState` info.
    func floraKit(_ floraKit: FloraKit, stateChanged state: FloraServiceState)
}

/// This class is only a wrapper class around FloraService to avoid exposing unecessary delegate methods
public class FloraKit: NSObject {
    public static let defaultScanDuration: Int = FloraService.defaultScanDuration
    public static let defaultReadTimeout: Int = FloraService.defaultReadTimeout
    private let floraService: FloraService = FloraService()
    public weak var delegate: FloraKitDelegate?
    
    public override init() {
        super.init()
        self.floraService.delegate = self
    }

    ///
    /// Scan for flora devices
    /// - Parameters:
    ///   - duration: Scanning duration in seconds (if not applied `FloraService.defaultScanDuration` is used).
    ///   - completion: Flora device UUID´s.
    public func scan(withDuration duration: Int = FloraKit.defaultScanDuration, completion: @escaping (_ floraDevices: [UUID]) -> Void) {
        self.floraService.scan(withDuration: duration, completion: completion)
    }

    ///
    /// Start reading from flora devices
    /// - Parameters:
    ///   - timeout: Reading timeout in seconds (if not applied `FloraService.defaultReadTimeout` is used).
    ///   - uuids: The UUID´s for flora devices to read from.
    public func read(withTimeout timeout: Int = FloraKit.defaultReadTimeout, uuids: [UUID]) {
        self.floraService.read(withTimeout: timeout, uuids: uuids)
    }
}

extension FloraKit: FloraServiceDelegate {
    func floraService(_ service: FloraService, stateChanged state: FloraServiceState) {
        self.delegate?.floraKit(self, stateChanged: state)
    }
}
