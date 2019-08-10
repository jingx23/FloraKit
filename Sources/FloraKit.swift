//
//  FloraKit.swift
//  FloraKit
//
//  Created by Jan Scheithauer on 10 Jun 2019.
//  Copyright © 2019 Jan Scheithauer. All rights reserved.
//

// Include Foundation
@_exported import Foundation

public class FloraKit: NSObject {
    private let floraService = FloraService()

    public func start() {
        floraService.delegate = self
        floraService.scan(duration: 5) {[weak self] peripherals in
            for peripheral in peripherals {
                self?.floraService.read(peripheral: peripheral)
            }
            print("Whoop: \(peripherals.count)")
            /*_ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
             self?.floraService.read(peripheral: peripheral)
             }*/
        }
    }
}

extension FloraKit: FloraServiceDelegate {
    func floraService(_ service: FloraService, didRecieveSensorData sensorData: FloraService.SensorData) {
        print(sensorData.debugDescription)
    }
}
