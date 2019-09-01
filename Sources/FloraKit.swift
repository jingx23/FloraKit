//
//  FloraKit.swift
//  FloraKit
//
//  Created by Jan Scheithauer on 10 Jun 2019.
//  Copyright © 2019 Jan Scheithauer. All rights reserved.
//

// Include Foundation
@_exported import Foundation

public protocol FloraKitDelegate: class {
    func floraKit(_ floraKit: FloraKit, didRecieveSensorData sensorData: FloraSensorData)
}

public class FloraKit: NSObject {
    private let floraService: FloraService = FloraService()
    public weak var delegate: FloraKitDelegate?
    
    convenience override public init() {
        self.init(scanDuration: nil)
    }
    
    public init(scanDuration: Int?) {
        super.init()
        self.floraService.scanDuration = scanDuration ?? FloraService.defaultScanDuration
        self.floraService.delegate = self
    }
    
    public func scan(completion: @escaping (_ floraDevices: [UUID]) -> Void) {
        self.floraService.scan(completion: completion)
    }
    
    public func read(uuids: [UUID]) {
        self.floraService.read(uuids: uuids)
    }

    public func readAll() {
        self.floraService.readAll()
    }
}

extension FloraKit: FloraServiceDelegate {
    func floraService(_ service: FloraService, didRecieveSensorData sensorData: FloraSensorData) {
        print(sensorData.debugDescription)
        self.delegate?.floraKit(self, didRecieveSensorData: sensorData)
    }
}
